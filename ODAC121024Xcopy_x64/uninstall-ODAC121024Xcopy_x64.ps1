#######################
<#
.SYNOPSIS
Uninstalls xcopy version of ODAC 12.1.0.2 x64.
.DESCRIPTION
The uninstall-odac121024xcopy_x64.ps1 script Uninstalls xcopy version of ODAC 12.1.0.2 x64.
.EXAMPLE
./uninstall-odac121024xcopy_x64.ps1 -oracle_home "C:\Oracle\product\12.1.0\xclient_1"
This command uninstalls and unconfigures all components for oracle_home.
.NOTES
Version History
v1.0   - Chad Miller - 11/24/2015 - Initial release
#>
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$false)]
    [string]$oracle_home = "C:\Oracle\product\12.1.0\xclient_1"
)


#######################
$ErrorActionPreference = "Stop"

$scriptRoot = "C:\orainstall"

$items = @(
"$scriptRoot\ODAC121024Xcopy_x64.zip"
"$scriptRoot\unzip.exe"
)

$logfile ="$env:TEMP\rjODACInstall$(get-date -f yyyy-MM-dd_HH-MM-ss).log"

#######################
function Test-IsAdmin {
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
} #Test-IsAdmin

#######################
function Reset-MachinePath {
    param($path)
    
    if ((get-itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name Path -ErrorAction SilentlyContinue).Path -split ";" -contains "$path") {
    
    $oldPath = [Environment]::GetEnvironmentVariable("Path","Machine")
    Write-Output "INFO: OLDPATH=$oldPath"

    if ($oldPath) {
        $newPath = $oldPath.Replace("$path;","")
    } 

    try {
        if ($newPath) {
            [Environment]::SetEnvironmentVariable("Path", $newpath, "Machine")
        }
    }

    catch { throw "$path failed to remove from path."}
    }

} #Reset-machinepath

#######################
write-output "You can find the log of this install session at: $logfile"

try {

    start-transcript $logfile

    write-output "1. check if admin..."
    if (!(Test-IsAdmin)) {
        throw "Please run this script with admin priviliges"
    }

    write-output "2. check files exist in current directory..."
    foreach ($item in $items) {
        if (!(Test-Path "$item")) {
            throw "Missing $item"
        }
    }

    write-output "3. unzipping install files..."
    & "$scriptRoot\unzip.exe"  -o -q "$scriptRoot\ODAC121024Xcopy_x64.zip" -d "$scriptRoot\ODAC121024Xcopy_x64"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }

    write-output "4. Run uninstall.bat..."
    write-output "...push-location $scriptRoot\ODAC121024Xcopy_x64"
    push-location "$scriptRoot\ODAC121024Xcopy_x64"
    
    & ".\uninstall.bat" "all" "$oracle_home"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }

    write-output "...pop-location"
    pop-location
    
    write-output "5. Remove $oracle_home if exists..."
    if (Test-Path "$oracle_home") {
        remove-item -Recurse -Force "$oracle_home"
    }
    write-output "6. UnSet system environment path variable for $oracle_home..."
    Reset-MachinePath "$oracle_home"

    write-output "7. UnSet system environment path variable for $oracle_home\bin..."
    Reset-MachinePath "$oracle_home\bin"

    write-output @"
Successfully uinstalled Software.
The uninstallation of ODAC xCopy was successful.
Please check $logfile for more details.
"@

}

catch {
    $_ | Out-String
write-output @"
Failed Uninstall Software.
The uninstallation of ODAC xCopy failed.
Please check $logfile for more details.
"@
    throw
}

finally {
    stop-transcript
}