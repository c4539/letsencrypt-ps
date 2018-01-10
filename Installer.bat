rem need the certificate's thumbprint as the first argument
powershell.exe -ExecutionPolicy Unrestricted -Command "Import-Module WebAdministration; Set-ItemProperty IIS:\SslBindings\* -Name Thumbprint -Value %1"
