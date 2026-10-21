<#
.SYNOPSIS
  Remove o GLPI Desktop Client em silêncio (reversão do Instalar-GlpiDesktopClient.ps1).
  Roda como SYSTEM (RMM, Intune, GPO). Use -ApagarConfig para remover também
  C:\ProgramData\GlpiDesktopClient. Os dados por usuário (%APPDATA%\GLPI Desktop Client:
  token cifrado, estado, logs) não são apagados.
#>
param([switch] $ApagarConfig)

$NomeApp = 'GLPI Desktop Client'
# O instalador grava "GLPI Desktop Client 0.7.0" em Aplicativos instalados (nome + versão)
$FiltroNome = '^GLPI Desktop Client( [0-9][0-9.]*)?$'
$ErrorActionPreference = 'Stop'

try {
    $item = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match $FiltroNome } | Select-Object -First 1
    if (-not $item) {
        Write-Output 'GLPI Desktop Client não está instalado.'
    } else {
        Get-Process -Name $NomeApp -ErrorAction SilentlyContinue | Stop-Process -Force
        if ($item.UninstallString -match 'msiexec') {
            $p = Start-Process msiexec.exe -ArgumentList "/x $($item.PSChildName) /qn /norestart" -Wait -PassThru
        } else {
            # NSIS: UninstallString vem entre aspas; /S = silencioso
            $exe = ($item.UninstallString -replace '"', '') -replace '\s+/.*$', ''
            $p = Start-Process -FilePath $exe -ArgumentList '/S' -Wait -PassThru
        }
        Write-Output "Desinstalador saiu com código $($p.ExitCode)"
    }

    if ($ApagarConfig) {
        Remove-Item (Join-Path $env:ProgramData 'GlpiDesktopClient') -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output 'Configuração da máquina removida.'
    }
    exit 0
}
catch {
    Write-Output "ERRO: $($_.Exception.Message)"
    exit 1
}
