$webconfigfilename = ".\Test\web.config"
[XML] $webconf = Get-Content $webconfigfilename
$webconf.OuterXml.ToString() | Out-File ".\Test\web_before.config"
$webconf.configuration.'system.webServer'.RemoveChild($webconf.configuration.'system.webServer'.handlers)
$webconf.OuterXml.ToString() | Out-File -Encoding utf8 ".\Test\web_after.config"