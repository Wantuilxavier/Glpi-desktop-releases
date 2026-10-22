<#
.SYNOPSIS
  Atualiza o GLPI Desktop Client numa estacao e reabre o app, minimizado, para quem estiver logado.
  Feito para RMM que roda script como SYSTEM (Tactical RMM, Intune, GPO de inicializacao).

.DESCRIPTION
  Em ordem:
  1. Versao instalada = -Versao (e sem -Forcar): sai com 0, sem baixar nada.
  2. Baixa o instalador (.exe NSIS, por maquina, em C:\Program Files) ou copia de um caminho de rede
     e confere o SHA-256. Nao confere: sai com 1, sem instalar.
  3. Fecha o app em todas as sessoes: primeiro de forma educada (app 0.13.0 ou mais novo: tarefa
     agendada temporaria com "--fechar" na sessao do usuario, igual ao "Fechar" da bandeja; versoes
     antigas: taskkill sem /F); o que ainda estiver aberto depois de -EsperaFecharSeg e encerrado a forca.
  4. Instala em silencio (/S + -ArgumentosInstalador) e confere o codigo de saida E a versao instalada
     (registro "Aplicativos instalados" e versao do arquivo do .exe).
  5. Para cada usuario com sessao interativa ATIVA (console ou area de trabalho remota conectada), abre
     o app com --minimizado na sessao dele, por tarefa agendada temporaria (roda como o usuario logado,
     sem privilegio elevado), e apaga a tarefa. Sessao desconectada ou ninguem logado: nao abre (o app
     sobe sozinho no proximo logon pelo Run do HKLM) e registra no log.

  Codigos de saida: 0 ok (ou ja estava na versao) | 1 erro antes de instalar (download, SHA-256,
  parametros) | 2 instalacao falhou ou nao confirmada | 3 instalado, mas nao reabriu para algum usuario.
  Log: %ProgramData%\GlpiDesktopClient\logs\atualizar-<data>.log (o instalador NSIS nao grava log
  proprio; o codigo de saida dele fica neste log).

  Sem senha, chave ou token: o instalador vem de uma URL publica (ou caminho de rede) e e conferido
  pelo SHA-256.

.EXAMPLE
  .\Atualizar-GlpiDesktopClient.ps1 -Versao 0.13.0 -Sha256 <SHA-256 do SHA256SUMS.txt> `
    -Instalador "https://github.com/Wantuilxavier/Glpi-desktop-releases/releases/download/v0.13.0/GLPI-Desktop-Client-Setup-0.13.0.exe" `
    -ArgumentosInstalador '/GLPI_URL=https://glpi.exemplo.com.br /APP_NAME="Central de Atendimento"'

.NOTES
  Requer app 0.13.0 ou mais novo para o --minimizado (versoes antigas abririam a janela).
  Como reverter: rodar de novo com a versao anterior e -Forcar (o instalador NSIS aceita instalar uma
  versao menor por cima), ou desinstalar:
  "C:\Program Files\GLPI Desktop Client\Uninstall GLPI Desktop Client.exe" /S
#>
param(
    [Parameter(Mandatory)] [ValidatePattern('^\d+\.\d+\.\d+$')] [string] $Versao,
    [Parameter(Mandatory)] [ValidatePattern('^[0-9a-fA-F]{64}$')] [string] $Sha256,
    [Parameter(Mandatory)] [string] $Instalador,          # https://... ou caminho local/UNC do .exe
    [string] $ArgumentosInstalador = '',                  # ex.: /GLPI_URL=https://glpi.exemplo.com.br
    [int]    $EsperaFecharSeg = 10,
    [switch] $Forcar                                      # reinstala mesmo se a versao ja estiver instalada
)

# ---------- CONFIGURACAO ----------
$NomeProcesso = 'GLPI Desktop Client'
$Exe          = Join-Path $env:ProgramFiles 'GLPI Desktop Client\GLPI Desktop Client.exe'
$FiltroNome   = '^GLPI Desktop Client( [0-9][0-9.]*)?$'   # DisplayName em "Aplicativos instalados"
$ChavesUninst = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$PastaBase    = Join-Path $env:ProgramData 'GlpiDesktopClient'
$PastaLog     = Join-Path $PastaBase 'logs'
$PastaTemp    = Join-Path $PastaBase 'atualizacao'
$PrefixoTarefa = 'GLPI Desktop Client - '
$MinimoFecharEducado = '0.13.0'                           # primeira versao com --fechar
# ----------------------------------

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

New-Item -ItemType Directory -Force -Path $PastaLog, $PastaTemp | Out-Null
$ArquivoLog = Join-Path $PastaLog ('atualizar-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

function Log([string] $texto) {
    $linha = '{0} {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $texto
    Add-Content -Path $ArquivoLog -Value $linha -Encoding UTF8
    Write-Output $texto
}

# Sessoes do Windows (WTS): id, estado, usuario. Nao depende do idioma (quser depende).
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class SessoesWts {
    [StructLayout(LayoutKind.Sequential)]
    struct WTS_SESSION_INFO { public int SessionId; public IntPtr WinStationName; public int State; }
    [DllImport("wtsapi32.dll", EntryPoint = "WTSEnumerateSessionsW")] static extern bool WTSEnumerateSessions(IntPtr h, int r, int v, out IntPtr p, out int n);
    [DllImport("wtsapi32.dll", EntryPoint = "WTSQuerySessionInformationW")] static extern bool WTSQuerySessionInformation(IntPtr h, int s, int c, out IntPtr p, out int n);
    [DllImport("wtsapi32.dll")] static extern void WTSFreeMemory(IntPtr p);
    static string Texto(int sessao, int classe) {
        IntPtr p; int n;
        if (!WTSQuerySessionInformation(IntPtr.Zero, sessao, classe, out p, out n)) return "";
        try { return Marshal.PtrToStringUni(p) ?? ""; } finally { WTSFreeMemory(p); }
    }
    // Uma linha por sessao com usuario: "id|estado|DOMINIO\usuario" (estado 0 = ativa).
    public static string[] Listar() {
        var saida = new List<string>();
        IntPtr p; int n;
        if (!WTSEnumerateSessions(IntPtr.Zero, 0, 1, out p, out n)) return saida.ToArray();
        try {
            int tam = Marshal.SizeOf(typeof(WTS_SESSION_INFO));
            for (int i = 0; i < n; i++) {
                var s = (WTS_SESSION_INFO)Marshal.PtrToStructure(new IntPtr(p.ToInt64() + i * tam), typeof(WTS_SESSION_INFO));
                string usuario = Texto(s.SessionId, 5), dominio = Texto(s.SessionId, 7);   // WTSUserName, WTSDomainName
                if (usuario.Length == 0) continue;
                saida.Add(s.SessionId + "|" + s.State + "|" + (dominio.Length > 0 ? dominio + "\\" : "") + usuario);
            }
        } finally { WTSFreeMemory(p); }
        return saida.ToArray();
    }
}
'@

function Get-Sessoes {
    foreach ($l in [SessoesWts]::Listar()) {
        $id, $estado, $usuario = $l.Split('|', 3)
        [pscustomobject]@{ Id = [int]$id; Ativa = ($estado -eq '0'); Usuario = $usuario }
    }
}

function Get-VersaoRegistro {
    $item = Get-ItemProperty $ChavesUninst -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match $FiltroNome } | Select-Object -First 1
    if ($item) { return [string]$item.DisplayVersion }
    return $null
}

function Get-VersaoArquivo {
    if (-not (Test-Path $Exe)) { return $null }
    $v = (Get-Item $Exe).VersionInfo
    return ('{0}.{1}.{2}' -f $v.FileMajorPart, $v.FileMinorPart, $v.FileBuildPart)
}

function Test-VersaoMaiorOuIgual([string] $a, [string] $b) {
    try { return ([version]$a) -ge ([version]$b) } catch { return $false }
}

# Roda o app na sessao do usuario, como ele (sem elevacao), por tarefa agendada temporaria.
# Devolve $true se a tarefa foi criada e iniciada.
function Invoke-NaSessao([string] $usuario, [string] $argumentos) {
    $nome = $PrefixoTarefa + [guid]::NewGuid().ToString('N').Substring(0, 8)
    try {
        $acao = New-ScheduledTaskAction -Execute $Exe -Argument $argumentos
        $quem = New-ScheduledTaskPrincipal -UserId $usuario -LogonType Interactive -RunLevel Limited
        $config = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
        Register-ScheduledTask -TaskName $nome -Action $acao -Principal $quem -Settings $config -Force | Out-Null
        Start-ScheduledTask -TaskName $nome
        Start-Sleep -Seconds 3
        return $true
    } catch {
        Log "  ERRO ao rodar '$argumentos' para $usuario : $($_.Exception.Message)"
        return $false
    } finally {
        Unregister-ScheduledTask -TaskName $nome -Confirm:$false -ErrorAction SilentlyContinue
    }
}

function Close-App([string] $versaoInstalada) {
    $abertos = @(Get-Process -Name $NomeProcesso -ErrorAction SilentlyContinue)
    if (-not $abertos) { Log 'App fechado em todas as sessoes.'; return }
    $sessoesComApp = $abertos | Select-Object -ExpandProperty SessionId -Unique
    Log "App aberto em $(@($sessoesComApp).Count) sessao(oes): fechando de forma educada."
    $educado = $versaoInstalada -and (Test-VersaoMaiorOuIgual $versaoInstalada $MinimoFecharEducado)
    $porSessao = @{}
    foreach ($s in Get-Sessoes) { $porSessao[$s.Id] = $s.Usuario }
    foreach ($id in $sessoesComApp) {
        $usuario = $porSessao[[int]$id]
        if ($educado -and $usuario) {
            Log "  sessao $id ($usuario): --fechar"
            Invoke-NaSessao $usuario '--fechar' | Out-Null
        } else {
            Log "  sessao $id ($(if ($usuario) { $usuario } else { 'sem usuario' })): taskkill sem /F (versao sem --fechar)"
            # Como SYSTEM, o Windows costuma recusar o taskkill sem /F em outra sessao; a recusa nao
            # e erro aqui (o que nao fechar e encerrado a forca abaixo). Via cmd: no PowerShell 5.1 o
            # stderr de um executavel vira excecao com $ErrorActionPreference = 'Stop'.
            foreach ($p in $abertos | Where-Object { $_.SessionId -eq $id }) {
                & cmd.exe /c "taskkill /PID $($p.Id) >nul 2>&1"
            }
        }
    }
    $limite = (Get-Date).AddSeconds($EsperaFecharSeg)
    while ((Get-Date) -lt $limite -and (Get-Process -Name $NomeProcesso -ErrorAction SilentlyContinue)) { Start-Sleep -Milliseconds 500 }
    $resto = @(Get-Process -Name $NomeProcesso -ErrorAction SilentlyContinue)
    if ($resto) {
        Log "Ainda aberto depois de $EsperaFecharSeg s: encerrando a forca ($($resto.Count) processo(s))."
        $resto | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } else {
        Log 'Fechou de forma educada.'
    }
}

$antes = $null
$depois = $null
$etapa = 'antes'          # antes | instalacao | reabertura (codigo de saida de um erro inesperado: 1, 2 ou 3)
$reabertos = @()
$naoReabertos = @()
try {
    Log "GLPI Desktop Client: atualizar para $Versao (log em $ArquivoLog)"
    $antes = Get-VersaoRegistro
    Log "Versao anterior: $(if ($antes) { $antes } else { 'nao instalado' })"
    if ($antes -eq $Versao -and -not $Forcar) {
        Log "RESUMO: versao anterior $antes | versao nova $Versao (ja instalada, nada feito) | app reaberto para: ninguem"
        exit 0
    }

    # 2. Instalador + SHA-256
    $destino = Join-Path $PastaTemp ("GLPI-Desktop-Client-Setup-{0}-{1}.exe" -f $Versao, [guid]::NewGuid().ToString('N').Substring(0, 8))
    try {
        if ($Instalador -match '^https://') {
            Log "Baixando $Instalador"
            Invoke-WebRequest -Uri $Instalador -OutFile $destino -UseBasicParsing
        } elseif ($Instalador -match '^[a-z]+://') {
            throw 'so https:// ou caminho local/UNC'
        } else {
            Log "Copiando $Instalador"
            Copy-Item -Path $Instalador -Destination $destino
        }
        $hash = (Get-FileHash -Path $destino -Algorithm SHA256).Hash
        if ($hash -ne $Sha256.ToUpperInvariant()) { throw "SHA-256 nao confere (esperado $($Sha256.ToUpperInvariant()), obtido $hash)" }
        Log 'SHA-256 conferido.'
    } catch {
        Remove-Item $destino -Force -ErrorAction SilentlyContinue
        Log "ERRO antes de instalar: $($_.Exception.Message)"
        exit 1
    }

    # 3. Fecha o app em todas as sessoes
    Close-App $antes

    # 4. Instala e confere
    $etapa = 'instalacao'
    $argumentos = ('/S ' + $ArgumentosInstalador).Trim()
    Log "Instalando: $(Split-Path $destino -Leaf) $argumentos"
    $proc = Start-Process -FilePath $destino -ArgumentList $argumentos -Wait -PassThru
    Remove-Item $destino -Force -ErrorAction SilentlyContinue
    # Um app aberto pelo proprio instalador rodaria como SYSTEM, fora da sessao do usuario.
    Get-Process -Name $NomeProcesso -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq 0 } | Stop-Process -Force -ErrorAction SilentlyContinue
    $depois = Get-VersaoRegistro
    $arquivo = Get-VersaoArquivo
    Log "Codigo de saida do instalador: $($proc.ExitCode) | versao no registro: $depois | versao do arquivo: $arquivo"
    if ($proc.ExitCode -ne 0 -or $depois -ne $Versao -or $arquivo -ne $Versao) {
        Log "ERRO: instalacao nao confirmada (esperado $Versao)."
        Log "RESUMO: versao anterior $(if ($antes) { $antes } else { 'nenhuma' }) | versao nova NAO instalada | app reaberto para: ninguem"
        exit 2
    }
    Log 'Instalacao confirmada.'

    # 5. Reabre minimizado para cada usuario com sessao ativa
    $etapa = 'reabertura'
    $sessoes = @(Get-Sessoes)
    $ativas = @($sessoes | Where-Object { $_.Ativa })
    foreach ($s in $sessoes | Where-Object { -not $_.Ativa }) { Log "Sessao $($s.Id) ($($s.Usuario)) desconectada: nao reaberto (abre no proximo logon)." }
    if (-not $ativas) { Log 'Nenhum usuario com sessao ativa: app nao reaberto (abre no proximo logon).' }
    foreach ($usuario in $ativas | Select-Object -ExpandProperty Usuario -Unique) {
        Log "Abrindo o app minimizado para $usuario"
        if (Invoke-NaSessao $usuario '--minimizado') { $reabertos += $usuario } else { $naoReabertos += $usuario }
    }
    # Confere: um processo do app por usuario reaberto (pode levar alguns segundos para subir).
    Start-Sleep -Seconds 5
    $porSessaoApp = @(Get-Process -Name $NomeProcesso -ErrorAction SilentlyContinue | Select-Object -ExpandProperty SessionId -Unique)
    foreach ($s in $ativas) {
        if ($reabertos -contains $s.Usuario -and $porSessaoApp -notcontains $s.Id) {
            Log "  aviso: app nao apareceu na sessao $($s.Id) ($($s.Usuario))"
            $reabertos = @($reabertos | Where-Object { $_ -ne $s.Usuario }); $naoReabertos += $s.Usuario
        }
    }

    $lista = if ($reabertos) { $reabertos -join ', ' } else { 'ninguem' }
    $falhas = if ($naoReabertos) { " | NAO reaberto para: $($naoReabertos -join ', ')" } else { '' }
    Log "RESUMO: versao anterior $(if ($antes) { $antes } else { 'nenhuma' }) | versao nova $depois | app reaberto para: $lista$falhas"
    if ($naoReabertos) { exit 3 }
    exit 0
}
catch {
    Log "ERRO inesperado ($etapa): $($_.Exception.Message)"
    Log "RESUMO: versao anterior $(if ($antes) { $antes } else { 'nenhuma' }) | versao nova $(if ($depois -eq $Versao) { $depois } else { 'NAO instalada' }) | app reaberto para: $(if ($reabertos) { $reabertos -join ', ' } else { 'ninguem' })"
    switch ($etapa) { 'antes' { exit 1 } 'instalacao' { exit 2 } default { exit 3 } }
}
