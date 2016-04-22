$ErrorActionPreference = "Stop"

$sourcePath = "\\vmware-host\Shared Folders\Desktop\ODTforVS2015"

if (!(Test-Path "c:\orainstall")) {
    new-item "c:\orainstall" -type directory | out-null
}

net.exe use $sourcePath | out-null

if ($LASTEXITCODE -ne 0) {
    throw "Unable to access $sourcePath"
}

$downloads = @(
"$sourcePath\install-ODT.ps1"
"$sourcePath\uninstall-ODT.ps1"
"$sourcePath\test-oracleconnect.ps1"
"$sourcePath\SetupODTforVS2015.iss"
"$sourcePath\Tnsadmin"
)

$counter = 0
foreach ($download in $downloads) {
    $status = "Copying file {0} of {1}: {2}" -f $counter, $downloads.count, $download
    Write-Progress -Activity "Copyng Files" -Status $status -PercentComplete ($counter/$downloads.count * 100)
    copy-item -path "$download" -destination "c:\orainstall" -Recurse -force
    $counter++
}