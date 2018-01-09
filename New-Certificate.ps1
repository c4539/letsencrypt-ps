# Import module ACMESharp (if not yet loaded)
if (! (Get-Module ACMESharp)) {
    # Import ACMESharp module
    Import-Module ACMESharp
}

# Import configuration
. (Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'config.ps1')

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

$Domain = Read-Host -Prompt "FQDN"
$Alias = $Domain + "-$(get-date -format yyyy-MM-dd--HH-mm)"
$Certname = $Domain + "-$(get-date -format yyyy-MM-dd--HH-mm)"

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
    Exit
}

# Generate Certificate
New-ACMECertificate -Generate -IdentifierRef $Alias -Alias $Certname

# Submit the certificate request to Let's Encrypt
Submit-ACMECertificate -CertificateRef $Certname

# Update in order to retrieve the CA signer's public cert
Update-ACMECertificate -CertificateRef $Certname

# Install Certificate
Install-ACMECertificate -CertificateRef $Certname -Installer iis -InstallerParameters @{
    WebSiteRef = $GLOBAL:ISSWebSite
    BindingHost = $Domain
    BindingPort = 443
    CertificateFriendlyName = $Certname
    Force = $true
  }
