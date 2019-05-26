. (Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath '..\Config\Config.ps1')

function Import-Domains {
    $FileContent = Get-Content -Path $GLOBAL:DomainListFile
    $Lines = $FileContent -split "`n" | `
        ForEach-Object { $_.ToString().Trim() -replace '\s+', ' ' } | `
        Where-Object -FilterScript { $_.ToString().Trim() -ne "" -and $_.ToString().Trim() -notlike "#*" }
    $Lines
}

Import-Domains