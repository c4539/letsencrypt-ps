# Enable extension modules needed for IIS
Import-Module ACMESharp
Enable-ACMEExtensionModule -ModuleName ACMESharp.Providers.IIS

# Import configuration
. (Join-Path -Path (Split-Path -Path $PSCommandPath -Parent) -ChildPath 'config.ps1')

# Verify the module was enabled
#Get-ACMEExtensionModule | Select-Object -Expand Name

# Initialize a local ACMESharp Vault to store states and assets
Initialize-ACMEVault

# Register Account
# TODO: Prompt for email address / contact information if $GLOBAL:AcemeContact is empty or unset
#$MailAddress = Read-Host -Prompt "Enter your e-mail address"
New-ACMERegistration -Contacts $GLOBAL:AcemeContact -AcceptTos
