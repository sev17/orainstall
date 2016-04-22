#######################
<#
.SYNOPSIS
Installs xcopy version of ODAC 12.1.0.2 x64.
.DESCRIPTION
The install-odac121024xcopy_x64.ps1 script Installs xcopy version of ODAC 12.1.0.2 x64.
.EXAMPLE
./install-odac121024xcopy_x64.ps1 -Component basic,odp.net2,asp.net2,oledb
This command installs and configures instant client (basic), odp.net2, asp.net2 and oledb.
.NOTES
Version History
v1.0   - Chad Miller - 11/24/2015 - Initial release
#>
[CmdletBinding()]
    param(
    [Parameter(Mandatory=$false)]
    [string]$oracle_home = "C:\Oracle\product\12.1.0\xclient_1",
    [Parameter(Mandatory=$false)]
    [string]$oracle_home_name = "xclient_1",
    [Parameter(Mandatory=$true)]
    [ValidateSet("all","basic","odp.net2","odp.net4","asp.net2","asp.net4","oledb","oramts")]
    [string[]]$component = ("all","basic","odp.net2","odp.net4","asp.net2","asp.net4","oledb","oramts")
)


#######################
$ErrorActionPreference = "Stop"

$scriptRoot = "C:\orainstall"

$items = @(
"$scriptRoot\ODAC121024Xcopy_x64.zip"
"$scriptRoot\unzip.exe"
"$scriptRoot\uninstall-ODAC121024Xcopy_x64.ps1"
"$scriptRoot\test-oracleconnect.ps1"
"$scriptRoot\Tnsadmin"
)

$logfile ="$env:TEMP\rjODTInstall$(get-date -f yyyy-MM-dd_HH-MM-ss).log"

#######################
function Test-IsAdmin {
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

} #Test-IsAdmin

#######################
function invoke-install {
    param($comp)

    write-output "...install $comp..."
    & ".\install.bat" "$comp" "$oracle_home" "$oracle_home_name" "false"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }

} #invoke-install

#######################
function update-machinepath {
    param($path)

    #GUI way to mode User Environment Variable "Start > Run > rundll32 sysdm.cpl,EditEnvironmentVariables"
    if ((get-itemproperty -path HKCU:\Environment -Name Path -ErrorAction SilentlyContinue).Path -split ";" -notcontains "$path") {
        $oldPath = [Environment]::GetEnvironmentVariable("Path","Machine")
        Write-Output "INFO: OLDPATH=$oldPath"
        
        if ($oldPath) {
            $newPath = "$path;$oldPath"
        }
        else {
            $newpath = "$path"
        }

        try {
            [Environment]::SetEnvironmentVariable("Path", $newpath, "Machine")
        } 
        catch { 
            throw "$path failed to add to path."
        }
    }    

} #update-machinepath

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

    write-output "4. Create $oracle_home if not exists..."
    if (!(Test-Path "$oracle_home")) {
        new-item "$oracle_home" -type directory
    }

    write-output "5. Run installs..."
    write-output "...push-location $scriptRoot\ODAC121024Xcopy_x64"
    push-location "$scriptRoot\ODAC121024Xcopy_x64"
    
    if ($component -contains "all") {
        invoke-install "all"
    }
    else {
        foreach ($comp in $component) {
            invoke-install $comp
        }
    }

    write-output "...pop-location"
    pop-location

    write-output "6. Set system environment path variable for $oracle_home..."
    update-machinepath "$oracle_home"

    write-output "7. Set system environment path variable for $oracle_home_name\bin..."
    update-machinepath "$oracle_home\bin"

    write-output "8. Create TNS_ADMIN if not exists..."
    if (!(Test-Path "C:\Oracle\Tnsadmin")) {
        new-item "C:\Oracle\Tnsadmin" -type directory
    }

    write-output "9. Backup Tnsadmin files if exists..."
    if (Test-Path "c:\Oracle\Tnsadmin\ldap.ora") {
        get-content "c:\Oracle\Tnsadmin\ldap.ora" 
    }

    if (Test-Path "c:\Oracle\Tnsadmin\sqlnet.ora") {
        get-content "c:\Oracle\Tnsadmin\sqlnet.ora"
    }

    write-output "10. Copy Tnsadmin files and replace if exists..."
    copy-item "$scriptRoot\Tnsadmin\sqlnet.ora" C:\Oracle\Tnsadmin\sqlnet.ora -force
    copy-item "$scriptRoot\Tnsadmin\ldap.ora" C:\Oracle\Tnsadmin\ldap.ora -force

    write-output "11. Set TNS_ADMIN system envrionment variable..."
    setx TNS_ADMIN C:\Oracle\Tnsadmin /M

    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }
    
    write-output @"
Successfully Setup Software.
The installation of ODAC was successful.
Please check $logfile for more details.
"@
}

catch {
    $_ | Out-String
write-output @"
Failed Setup Software.
The installation of ODAC failed.
Please check $logfile for more details.
"@
    throw
}

finally {
    stop-transcript
}