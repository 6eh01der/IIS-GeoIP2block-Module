$ReleaseVersion=$args[0]
$InstallPath=$args[1]
Invoke-WebRequest https://github.com/6eh01der/IIS-GeoIP2block-Module/releases/download/$ReleaseVersion/IIS-GeoIP2block-Module-$ReleaseVersion.zip -OutFile ${env:windir}\Temp\IIS-GeoIP2block-Module-$ReleaseVersion.zip
Invoke-WebRequest https://github.com/6eh01der/IIS-GeoIP2block-Module/raw/master/InstallScripts/IISManagerGeoBlockReg.vbs -OutFile ${env:windir}\Temp\IISManagerGeoBlockReg.vbs
Expand-Archive -LiteralPath ${env:windir}\Temp\IIS-GeoIP2block-Module-$ReleaseVersion.zip -DestinationPath "${env:windir}\Temp\IIS-GeoIP2block-Module-$ReleaseVersion\"
Move-Item "${env:windir}\Temp\IIS-GeoIP2block-Module-$ReleaseVersion\release\geoblockModule_schema.xml" "${env:windir}\System32\inetsrv\config\schema\" -Force
$NewAcl = Get-Acl -Path "C:\Windows\System32\inetsrv\config\schema\geoblockModule_schema.xml"
$identity = "BUILTIN\Users"
$fileSystemRights = "Read"
$type = "Allow"
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path "C:\Windows\System32\inetsrv\config\schema\geoblockModule_schema.xml" -AclObject $NewAcl
if ( -not ( Test-Path $InstallPath )) {
  New-Item -Type Directory $InstallPath
}
Move-Item "${env:windir}\Temp\IIS-GeoIP2block-Module-$ReleaseVersion\release" "$InstallPath\IISGeoIP2blockModule" -Force
[System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")            
$publish = New-Object System.EnterpriseServices.Internal.Publish            
$publish.GacInstall("$InstallPath\IISGeoIP2blockModule\IISGeoIP2blockModule.dll")
add-webconfigurationproperty /system.webserver -name Sections -value geoblockModule
set-webconfigurationproperty /system.webserver -name Sections["geoblockModule"].overrideModeDefault -value Allow
New-WebManagedModule -Name "Geoblocker" -Type "IISGeoIP2blockModule.GeoblockHttpModule, IISGeoIP2blockModule, Version=$ReleaseVersion, Culture=neutral, PublicKeyToken=50262f380b75b73d" -Precondition "runtimeVersionv4.0"
."${env:windir}\Temp\IISManagerGeoBlockReg.vbs" "$ReleaseVersion"
Start-sleep -Seconds 5
Remove-Item ${env:windir}\Temp\IIS-GeoIP2block-Module-$ReleaseVersion.zip,${env:windir}\Temp\IISManagerGeoBlockReg.vbs -Force
