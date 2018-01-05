# Import module ACMESharp (if not yet loaded)
if (! (Get-Module ACMESharp)) {
    # Import ACMESharp module
    Import-Module ACMESharp
}

$ISSWebSite = "Default Web Site"

function Fix-WebConfig {
    $webconfigfilename = "C:\inetpub\wwwroot\.well-known\acme-challenge\web.config"
    [XML] $webconf = Get-Content $webconfigfilename
    $webconf.configuration.'system.webServer'.handlers.RemoveAll()
    $webconf.OuterXml.ToString() | Out-File $webconfigfilename
}

$Domain = Read-Host -Prompt "FQDN"
$Alias = $Domain + "-01"
$Certname = $Domain + "-$(get-date -format yyyy-MM-dd--HH-mm)"

# Create a new Identifier with Let's Encrypt
New-ACMEIdentifier -Dns $Domain -Alias $Alias

# Handle the challenge using HTTP validation on IIS
Complete-ACMEChallenge -IdentifierRef $Alias -ChallengeType http-01 -Handler iis -HandlerParameters @{ WebSiteRef = $ISSWebSite }

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
New-ACMECertificate -Generate -IdentifierRef $Alias  -Alias $Certname

# Submit the certificate request to Let's Encrypt
Submit-ACMECertificate -CertificateRef $Certname

# Update in order to retrieve the CA signer's public cert
Update-ACMECertificate -CertificateRef $Certname

# Install Certificate
Install-ACMECertificate -CertificateRef $Certname -Installer iis -InstallerParameters @{
    WebSiteRef = $ISSWebSite
    BindingHost = $Domain
    BindingPort = 443
    CertificateFriendlyName = 'LetsEncryptCert'
  }
