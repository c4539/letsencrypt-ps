#Requires -Version 5

param(
	[ValidateScript({Test-Path -PathType Container -Path $_ })]
	[Parameter(Mandatory=$true,Position=1)]
	[String[]]
	$Domains
,
	[ValidateScript({Test-Path -PathType Container -Path $_ })]
	[Parameter(Mandatory=$true,Position=2)]
	[String]
	$Destination
,
	[String]
	$TimeFormat="yyyy-MM-dd HH-mm-ss"
,
	[String]
	$Separator = " "
,
	[Switch]
	$UseSubfolders=$false
,
	[String]
	[ValidateSet("yyyy\\MM","yyyy-MM","yyyy")]
	$SubfolderFormat = "yyyy\\MM"
,
	[Switch]
	$Recurse=$false
,
	[String]
	[ValidateSet("UpperCase","LowerCase","Keep")]
	$ExtensionCase = "Keep"
)


# Install Certificate
Install-ACMECertificate -CertificateRef $Certname -Installer iis -InstallerParameters @{
    WebSiteRef = $GLOBAL:ISSWebSite
    BindingHost = $Domain
    BindingPort = 443
    CertificateFriendlyName = $Certname
    Force = $true
  }