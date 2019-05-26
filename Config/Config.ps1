# ACME Contact
$GLOBAL:AcemeContact = "mailto:<MailAddress>"

# IIS Web Site
$GLOBAL:ISSWebSite = "Default Web Site"

# Path to the web.config for the acme-challenge.
$GLOBAL:webconfigfilename = "C:\inetpub\wwwroot\.well-known\acme-challenge\web.config"

# Path to the domains.txt file
$GLOBAL:DomainListFile = (Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'Domains.txt') # Expects the Domains.txt in the same file as the Config.ps1

# Path to the hook script for successful renewals
$GLOBAL:HOOKSuccess = (Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'hook.ps1') # Expects the script in the same file as the Config.ps1