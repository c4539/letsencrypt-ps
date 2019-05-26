rem need the certificate's thumbprint as the first argument
powershell.exe -ExecutionPolicy Unrestricted -Command "Import-Module WebAdministration; Get-Item IIS:\SslBindings\* | Where-Object { $_.Store -eq 'WebHosting' } | Set-ItemProperty -Name Thumbprint -Value %1"
