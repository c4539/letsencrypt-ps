#Requires -Version 5

param(
	[Parameter(Mandatory=$true,Position=1)]
	[String]
	$Certname
,
	[Parameter(Mandatory=$true,Position=2)]
	[String[]]
	$Domains
)


if ($Domain[0] -eq "x") {
	# Install Certificate
	Install-ACMECertificate -CertificateRef $Certname -Installer iis -InstallerParameters @{
		WebSiteRef = $GLOBAL:ISSWebSite
		BindingHost = "x"
		BindingPort = 443
		CertificateFriendlyName = $Certname
		Force = $true
	}
}