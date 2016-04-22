$ErrorActionPreference = "Stop"

$sourcePath = "\\vmware-host\Shared Folders\Desktop\ODTwithODAC121024"

if (!(Test-Path "c:\orainstall")) {
    new-item "c:\orainstall" -type directory | out-null
}

net.exe use $sourcePath | out-null

if ($LASTEXITCODE -ne 0) {
    throw "Unable to access $sourcePath"
}

$downloads = @(
"$sourcePath\ODTwithODAC121024.rsp" 
"$sourcePath\ODTwithODAC121024.zip"
"$sourcePath\unzip.exe"
"$sourcePath\install-ODT.ps1"
"$sourcePath\uninstall-ODT.ps1"
"$sourcePath\test-oraclemanaged.ps1"
"$sourcePath\Tnsadmin"
)

$counter = 0
foreach ($download in $downloads) {
    $status = "Copying Item {0} of {1}: {2}" -f $counter, $downloads.count, $download
    Write-Progress -Activity "Copying Items" -Status $status -PercentComplete ($counter/$downloads.count * 100)
    copy-item -path "$download" -destination "c:\orainstall" -Recurse -force
    $counter++
}