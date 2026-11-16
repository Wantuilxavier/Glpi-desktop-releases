<#
.SYNOPSIS
  Instala/atualiza o GLPI Desktop Client em silêncio e grava a configuração da máquina.
  Para qualquer ferramenta que rode script como SYSTEM (RMM, Intune, GPO de inicialização).
  Idempotente: se a versão pedida já estiver instalada, só regrava o config.json e sai com 0.

.EXAMPLE
  .\Instalar-GlpiDesktopClient.ps1 -UrlInstalador "https://github.com/Wantuilxavier/Glpi-desktop-releases/releases/download/v0.19.0/GLPI-Desktop-Client-Setup-0.19.0.exe"
    -Versao "0.19.0" -Sha256 "<SHA-256 do SHA256SUMS.txt da release>" -GlpiUrl "https://glpi.exemplo.com.br" [-LockServer]
  -Sha256 é obrigatório e o instalador só vem por https:// ou caminho local/UNC (desde a 0.19.0).
  -AppToken e -DominiosSSO são opcionais: sem App-Token o app recebe o do plugin depois do login;
  sem domínios, o login do Windows vai só para o endereço do GLPI.
  -AppName "Suporte TI" (opcional, app 0.2.0 ou mais novo): nome que os usuários veem. Vai para o
  config.json e para o instalador (/APP_NAME=), que renomeia o atalho do Menu Iniciar. Com a versão
  já instalada, só o config.json muda: o atalho fica com o nome anterior até a próxima instalação.

.NOTES
  Reverter: Desinstalar-GlpiDesktopClient.ps1.
  Segurança (0.19.0): o instalador é baixado e conferido numa pasta nova só do SYSTEM e Administradores;
  a pasta %ProgramData%\GlpiDesktopClient passa a ser do SYSTEM, sem escrita para usuários comuns, e o
  config.json é recriado (o app só aceita esse arquivo se for do SYSTEM/Administradores).
#>
param(
    [Parameter(Mandatory)] [string] $UrlInstalador,   # https:// ou caminho local/UNC
    [Parameter(Mandatory)] [string] $Versao,
    [Parameter(Mandatory)] [string] $GlpiUrl,         # ex.: https://glpi.exemplo.com.br
    [string] $AppToken = '',                          # opcional
    [string] $DominiosSSO = '',                       # opcional, ex.: *.exemplo.com.br
    [Parameter(Mandatory)] [ValidatePattern('^[0-9a-fA-F]{64}$')] [string] $Sha256,
    [int]    $IntervaloMinutos = 2,
    [string] $AppName = '',                           # opcional, ex.: Suporte TI (app ≥ 0.2.0)
    [switch] $LockServer                              # o usuário não pode trocar de servidor
)

# ---- CONFIGURAÇÃO ---------------------------------------------------------------
$NomeApp      = 'GLPI Desktop Client'
# O instalador grava "GLPI Desktop Client 0.3.1" em Aplicativos instalados (nome + versão)
$FiltroNome   = '^GLPI Desktop Client( [0-9][0-9.]*)?$'
$PastaConfig  = Join-Path $env:ProgramData 'GlpiDesktopClient'
$ChavesUninst = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
# ---------------------------------------------------------------------------------

$ErrorActionPreference = 'Stop'

function Get-VersaoInstalada {
    $item = Get-ItemProperty $ChavesUninst -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match $FiltroNome } | Select-Object -First 1
    if ($item) { return $item.DisplayVersion }
    return $null
}

# Pasta nova, de nome aleatório, só para SYSTEM e Administradores (sem herança).
function New-PastaSegura {
    $p = Join-Path $env:windir ('Temp\GlpiDesktopClient-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $p | Out-Null
    & icacls.exe $p /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' | Out-Null
    if ($LASTEXITCODE -ne 0) { Remove-Item $p -Force -ErrorAction SilentlyContinue; throw "não foi possível proteger $p (icacls $LASTEXITCODE)" }
    return $p
}

# %ProgramData%\GlpiDesktopClient do SYSTEM: Usuários só leem. A pasta herda do ProgramData o direito de
# qualquer usuário criar arquivo; um link (junção) no lugar dela não é seguido.
function Protect-PastaConfig {
    if (Test-Path -LiteralPath $PastaConfig) {
        if ((Get-Item -LiteralPath $PastaConfig -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "$PastaConfig é um link (junção): apague-o antes de instalar"
        }
    } else {
        New-Item -ItemType Directory -Path $PastaConfig | Out-Null
    }
    & icacls.exe $PastaConfig /setowner '*S-1-5-18' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "não foi possível trocar o dono de $PastaConfig (icacls $LASTEXITCODE)" }
    & icacls.exe $PastaConfig /inheritance:r /grant:r '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F' '*S-1-5-32-545:(OI)(CI)RX' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "não foi possível proteger $PastaConfig (icacls $LASTEXITCODE)" }
}

function Gravar-Config {
    Protect-PastaConfig
    # Recriado (não sobrescrito): um config.json deixado por um usuário continuaria sendo dele.
    Remove-Item -LiteralPath (Join-Path $PastaConfig 'config.json') -Force -ErrorAction SilentlyContinue
    $cfg = [ordered]@{ glpiUrl = $GlpiUrl; intervaloMinutos = $IntervaloMinutos; lockServer = [bool]$LockServer }
    if ($AppToken)    { $cfg.appToken = $AppToken }
    if ($DominiosSSO) { $cfg.dominiosSSO = $DominiosSSO }
    if ($AppName)     { $cfg.appName = $AppName }
    $cfg | ConvertTo-Json | Out-File -FilePath (Join-Path $PastaConfig 'config.json') -Encoding utf8
    Write-Output "config.json gravado em $PastaConfig"
}

try {
    $antes = Get-VersaoInstalada
    Write-Output "Versão instalada antes: $(if ($antes) { $antes } else { 'nenhuma' })"

    Gravar-Config

    if ($antes -eq $Versao) {
        Write-Output "Versão $Versao já instalada — nada a fazer."
        exit 0
    }

    # Pasta nova só do SYSTEM/Administradores: ninguém troca o .exe entre a conferência e a execução.
    $pasta = New-PastaSegura
    $destino = Join-Path $pasta 'glpi-desktop-client-setup.exe'
    if ($UrlInstalador -match '^https://') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $UrlInstalador -OutFile $destino -UseBasicParsing
    } elseif ($UrlInstalador -match '^[a-z]+://') {
        throw 'o instalador só pode vir por https:// ou caminho local/UNC'
    } else {
        Copy-Item -Path $UrlInstalador -Destination $destino
    }

    $hash = (Get-FileHash $destino -Algorithm SHA256).Hash
    if ($hash -ne $Sha256.ToUpperInvariant()) { throw "SHA-256 não confere (obtido $hash)" }

    # O app aberto nas sessões dos usuários trava os arquivos da atualização.
    Get-Process -Name $NomeApp -ErrorAction SilentlyContinue | Stop-Process -Force

    # Com nome próprio, o instalador também renomeia o atalho do Menu Iniciar.
    $argumentos = if ($AppName) { '/S /APP_NAME="{0}"' -f $AppName } else { '/S' }
    $p = Start-Process -FilePath $destino -ArgumentList $argumentos -Wait -PassThru
    Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0) { throw "instalador saiu com código $($p.ExitCode)" }

    $depois = Get-VersaoInstalada
    Write-Output "Versão instalada depois: $depois"
    if ($depois -ne $Versao) { throw "esperava $Versao, encontrou '$depois'" }

    # O app sobe sozinho no próximo logon (Run do HKLM). Não abrimos nas sessões
    # dos usuários a partir do SYSTEM.
    exit 0
}
catch {
    if ($pasta) { Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Output "ERRO: $($_.Exception.Message)"
    exit 1
}
