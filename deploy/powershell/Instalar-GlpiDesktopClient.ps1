<#
.SYNOPSIS
  Instala/atualiza o GLPI Desktop Client em silêncio e grava a configuração da máquina.
  Para qualquer ferramenta que rode script como SYSTEM (RMM, Intune, GPO de inicialização).
  Idempotente: se a versão pedida já estiver instalada, só regrava o config.json e sai com 0.

.EXAMPLE
  .\Instalar-GlpiDesktopClient.ps1 -UrlInstalador "https://github.com/Wantuilxavier/Glpi-desktop-releases/releases/download/v0.9.0/GLPI-Desktop-Client-Setup-0.9.0.exe"
    -Versao "0.3.1" -Sha256 "<SHA-256 da release>" -GlpiUrl "https://glpi.exemplo.com.br" [-LockServer]
  -AppToken e -DominiosSSO são opcionais: sem App-Token o app recebe o do plugin depois do login;
  sem domínios, o login do Windows vai só para o endereço do GLPI.
  -AppName "Suporte TI" (opcional, app 0.2.0 ou mais novo): nome que os usuários veem. Vai para o
  config.json e para o instalador (/APP_NAME=), que renomeia o atalho do Menu Iniciar. Com a versão
  já instalada, só o config.json muda: o atalho fica com o nome anterior até a próxima instalação.

.NOTES
  Reverter: Desinstalar-GlpiDesktopClient.ps1.
#>
param(
    [Parameter(Mandatory)] [string] $UrlInstalador,   # http(s) ou caminho UNC
    [Parameter(Mandatory)] [string] $Versao,
    [Parameter(Mandatory)] [string] $GlpiUrl,         # ex.: https://glpi.exemplo.com.br
    [string] $AppToken = '',                          # opcional
    [string] $DominiosSSO = '',                       # opcional, ex.: *.exemplo.com.br
    [string] $Sha256 = '',
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

function Gravar-Config {
    New-Item -ItemType Directory -Force -Path $PastaConfig | Out-Null
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

    # Nome único em %TEMP% (execuções paralelas não se atropelam)
    $destino = Join-Path $env:TEMP ("glpi-desktop-client-{0}.exe" -f [guid]::NewGuid().ToString('N'))
    if ($UrlInstalador -match '^https?://') {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $UrlInstalador -OutFile $destino -UseBasicParsing
    } else {
        Copy-Item -Path $UrlInstalador -Destination $destino
    }

    if ($Sha256) {
        $hash = (Get-FileHash $destino -Algorithm SHA256).Hash
        if ($hash -ne $Sha256.ToUpper()) { throw "SHA-256 não confere (obtido $hash)" }
    }

    # O app aberto nas sessões dos usuários trava os arquivos da atualização.
    Get-Process -Name $NomeApp -ErrorAction SilentlyContinue | Stop-Process -Force

    # Com nome próprio, o instalador também renomeia o atalho do Menu Iniciar.
    $argumentos = if ($AppName) { '/S /APP_NAME="{0}"' -f $AppName } else { '/S' }
    $p = Start-Process -FilePath $destino -ArgumentList $argumentos -Wait -PassThru
    Remove-Item $destino -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -ne 0) { throw "instalador saiu com código $($p.ExitCode)" }

    $depois = Get-VersaoInstalada
    Write-Output "Versão instalada depois: $depois"
    if ($depois -ne $Versao) { throw "esperava $Versao, encontrou '$depois'" }

    # O app sobe sozinho no próximo logon (Run do HKLM). Não abrimos nas sessões
    # dos usuários a partir do SYSTEM.
    exit 0
}
catch {
    Write-Output "ERRO: $($_.Exception.Message)"
    exit 1
}
