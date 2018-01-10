# Import module ACMESharp (if not yet loaded)
if (! (Get-Module ACMESharp)) {
    # Import ACMESharp module
    Import-Module ACMESharp
}

# Import configuration
. (Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'Config\Config.ps1')

#$ISSWebSite = "Default Web Site"
# Moved to config.ps1

##############################
#.SYNOPSIS
#A quick fix for the web.config
#
#.DESCRIPTION
#This is a quick fix to remove unnecessary / incorrect configuration from the web.config file.
#
###############################
function Fix-WebConfig {
    #$webconfigfilename = "C:\inetpub\wwwroot\.well-known\acme-challenge\web.config"
    # Moved to config.ps1

    [XML] $webconf = Get-Content $GLOBAL:webconfigfilename
    $webconf.configuration.'system.webServer'.RemoveChild($webconf.configuration.'system.webServer'.handlers)
    $webconf.OuterXml.ToString() | Out-File -Encoding utf8 $GLOBAL:webconfigfilename
}

function Import-Domains {
    $FileContent = Get-Content -Path $GLOBAL:DomainListFile
    $Lines = $FileContent -split "`n" | `
        ForEach-Object { $_.ToString().Trim() -replace '\s+', ' ' } | `
        Where-Object -FilterScript { $_.ToString().Trim() -ne "" -and $_.ToString().Trim() -notlike "#*" }
    return $Lines
}

$DomainFileLines = Import-Domains

$DomainFileLines | ForEach-Object {
    $Domains = $_ -split " "

    $Primary = $Domains[0]
    $Certname = $Primary + "-$(get-date -format yyyy-MM-dd--HH-mm)"

    $Domains | ForEach-Object {
        $Domain = $_
        $Alias = $Domain #+ "-$(get-date -format yyyy-MM-dd--HH-mm)"

        # Create a new Identifier with Let's Encrypt
        New-ACMEIdentifier -Dns $Domain -Alias $Alias

        # Handle the challenge using HTTP validation on IIS
        Complete-ACMEChallenge -IdentifierRef $Alias -ChallengeType http-01 -Handler iis -HandlerParameters @{ WebSiteRef = $GLOBAL:ISSWebSite }

        # Fix web.config bug
        Fix-WebConfig

        # Tell Let's Encrypt it's OK to validate now
        Submit-ACMEChallenge -IdentifierRef $Alias -ChallengeType http-01

        # Check the status of the certificate every 6 seconds until we have an answer; fail after a minute
        $i = 0
        do {
            $IdentifierInfo = Update-ACMEIdentifier -IdentifierRef $Alias
            if($IdentifierInfo.Status.toString() -ne "pending") {
                Start-Sleep 6
                $i++
            }
        } until($IdentifierInfo.Status.toString() -ne "pending" -or $i -gt 10)

        if($i -gt 10) {
            Write-Error "We did not receive a completed certificate after 60 seconds"
            Continue
        }
    }

    # Generate Certificate
    New-ACMECertificate -Generate -IdentifierRef $Primary -AlternativeIdentifierRefs $Domains -Alias $Certname

    # Submit the certificate request to Let's Encrypt
    Submit-ACMECertificate -CertificateRef $Certname

    # Update in order to retrieve the CA signer's public cert
    Update-ACMECertificate -CertificateRef $Certname

    . $GLOBAL:HOOKSuccess 
}
