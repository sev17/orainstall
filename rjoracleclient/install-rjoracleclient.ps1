$ErrorActionPreference = "Stop"

$scriptRoot = "C:\orainstall"

function Test-IsAdmin {
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

#check if admin
if (!(Test-IsAdmin)) {
    throw "Please run this script with admin priviliges"
}

#check response file exists in current directory
if (!(Test-Path "$scriptRoot\oracle.client_11203.rsp")) {
    throw "Missing $scriptRoot\oracle.client_11203.rsp"
}

$installs = @(
    "$scriptRoot\Oracle11203Client.exe"
    "$scriptRoot\RJ-TNSADMIN_Installer_1_01.msi"
    "$scriptRoot\RJ-SQLDeveloper3_1_07_42.msi"
    "$scriptRoot\Oracle11203-SEFix.exe"
)

#check install file exists in current directory
foreach ($install in $installs) {
    if (!(Test-Path "$install")) {
        throw "Missing $install"
    }
}

#run installs
foreach ($install in $installs) {
    if ( [System.IO.Path]::GetExtension("$install") -eq '.msi') {
        $process = start-process -FilePath msiexec.exe -ArgumentList /i, $install, /quiet -Wait -PassThru
    }
    else {
        $process = start-process -FilePath $install -Wait -PassThru        
    }

    if ($process.ExitCode -ne 0) {
        throw "Installer Exit Code: $($process.ExitCode) for $install"
    }

}