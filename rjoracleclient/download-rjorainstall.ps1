$ErrorActionPreference = "Stop"

if (!(Test-Path "c:\orainstall")) {
    new-item "c:\orainstall" -type directory | out-null
}

net.exe use \\MyFileServer\ora_sup\Public | out-null

if ($LASTEXITCODE -ne 0) {
    throw "Unable to access \\MyFileServer\ora_sup\Public"
}

$downloads = @(
"\\MyFileServer\ora_sup\public\Windows-32bit\Oracle11203Client\oracle.client_11203.rsp" 
"\\MyFileServer\ora_sup\public\Windows-32bit\Oracle11203Client\Oracle11203Client.exe"
"\\MyFileServer\ora_sup\public\Windows-32bit\Oracle11203Client\Oracle11203-SEFix.exe"
"\\MyFileServer\ora_sup\public\Windows-32bit\SQLDeveloper\RJ-SQLDeveloper3_1_07_42.msi"
"\\MyFileServer\ora_sup\public\RJ-TNSADMIN_Installer_1_02.msi"
"\\MyFileServer\ora_sup\public\Testing\install-rjoracleclient.ps1"
"\\MyFileServer\ora_sup\public\Testing\uninstall-rjoracleclient.ps1"
)

$counter = 0
foreach ($download in $downloads) {
    $status = "Copying file {0} of {1}: {2}" -f $counter, $downloads.count, $download
    Write-Progress -Activity "Copyng Files" -Status $status -PercentComplete ($counter/$downloads.count * 100)
    copy-item -path "$download" -destination "c:\orainstall" -force
    $counter++
}