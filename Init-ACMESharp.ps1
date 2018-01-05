# Enable extension modules needed for IIS
Import-Module ACMESharp
Enable-ACMEExtensionModule -ModuleName ACMESharp.Providers.IIS

# Verify the module was enabled
Get-ACMEExtensionModule | Select-Object -Expand Name
# You should see this:
ACMESharp.Providers.IIS

# Initialize a local ACMESharp Vault to store states and assets
Initialize-ACMEVault

# Register Account
$MailAddress = Read-Host -Prompt "Enter your e-mail address"
New-ACMERegistration -Contacts mailto:$MailAddress -AcceptTos

