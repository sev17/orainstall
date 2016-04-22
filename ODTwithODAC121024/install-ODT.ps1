$ErrorActionPreference = "Stop"

$scriptRoot = "C:\orainstall"

$items = @(
    "$scriptRoot\ODTwithODAC121024.zip"
    "$scriptRoot\ODTwithODAC121024.rsp"
    "$scriptRoot\uninstall-ODT.ps1"
    "$scriptRoot\install-ODT.ps1"
    "$scriptRoot\Tnsadmin"
    "$scriptRoot\Tnsadmin\sqlnet.ora"
    "$scriptRoot\Tnsadmin\ldap.ora"
    "$scriptRoot\unzip.exe"
)

$logfile ="$env:TEMP\rjODTInstall$(get-date -f yyyy-MM-dd_HH-MM-ss).log"

function Test-IsAdmin {
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

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
    & "$scriptRoot/unzip.exe"  -o -q "$scriptRoot\ODTwithODAC121024.zip" -d "$scriptRoot\ODTwithODAC121024"

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to unzip $scriptRoot\ODTwithODAC121024.zip."
    }
    
    write-output "4. Set version of Visual Studio Oracle Development Tools (ODT)..."
    
    # By default PowerShell does not have HKEY_CLASSES_ROOT defined so we have to define it
    if ($(Get-PSDrive HKCR -ErrorAction SilentlyContinue) -eq $null) {New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT > $null}

    $vs = @{
    2012="false"
    2013="false"
    2015="false"}

    if (Test-Path HKCR:\VisualStudio.DTE.14.0) {
        $vs.2015="true"
    } 
    elseif (Test-Path HKCR:\VisualStudio.DTE.12.0) {
        $vs.2013="true"
    }
    elseif (Test-Path HKCR:\VisualStudio.DTE.11.0) {
        $vs.2012="true"
    }
    else { throw 'VisualStudio version 2012, 2013 or 2015 NOT FOUND!'}

$oldCode=@"
oracle.install.odac.odt.ConfigureVS2012=
oracle.install.odac.odt.ConfigureVS2013=
oracle.install.odac.odt.ConfigureVS2015=
"@

$newCode=@"
oracle.install.odac.odt.ConfigureVS2012=$vs.2012
oracle.install.odac.odt.ConfigureVS2013=$vs.2013
oracle.install.odac.odt.ConfigureVS2015=$vs.2015
"@

    write-output "5. Update rsp file with VS version..."
    $fileContent = [System.Io.File]::ReadAllText("$scriptRoot\ODTwithODAC121024.rsp")
    $newFileContent = $fileContent -replace $oldCode, $newCode
    Set-Content -Path "$scriptRoot\ODTwithODAC121024.rsp" -Value $newFileContent

    #OUI launches multiple processes, making trapping exit code difficult, so proceed on and check at end in step 10.
write-output @"
6. Run oui setup.exe using responseFile. 
   You can find the log of this install at C:\Program Files (x86)\Oracle\Inventory\logs..."
"@
    $args = @("-silent","-waitforcompletion","-nowait","-responseFile","`"$scriptRoot\ODTwithODAC121024.rsp`"")
    $process = start-process -FilePath "$scriptRoot\ODTwithODAC121024\setup.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru

    write-output "7. Create TNS_ADMIN if not exists..."
    if (!(Test-Path "C:\Oracle\Tnsadmin")) {
        new-item "C:\Oracle\Tnsadmin" -type directory
    }

    write-output "8. Backup Tnsadmin files if exists..."
    if (Test-Path "c:\Oracle\Tnsadmin\ldap.ora") {
        get-content "c:\Oracle\Tnsadmin\ldap.ora" 
    }

    if (Test-Path "c:\Oracle\Tnsadmin\sqlnet.ora") {
        get-content "c:\Oracle\Tnsadmin\sqlnet.ora"
    }

    write-output "9. Copy Tnsadmin files and replace if exists..."
    copy-item "$scriptRoot\Tnsadmin\sqlnet.ora" C:\Oracle\Tnsadmin\sqlnet.ora -force
    copy-item "$scriptRoot\Tnsadmin\ldap.ora" C:\Oracle\Tnsadmin\ldap.ora -force

    write-output "10. Set TNS_ADMIN system envrionment variable..."
    setx TNS_ADMIN C:\Oracle\Tnsadmin /M

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set TNS_ADMIN system envrionment variable."
    }
    
    write-output "11. Check ExitCode of OUI..."
    if ($process.ExitCode -ne 0) {
        throw "Installer Exit Code: $($process.ExitCode) for  $scriptRoot\ODTwithODAC121024\setup.exe"
    }

    write-output @"
Successfully Setup Software.
The installation of Oracle Developer Tools with ODAC was successful.
Please check $logfile for more details.
"@
}

catch {
    $_ | Out-String
write-output @"
Failed Setup Software.
The installation of Oracle Developer Tools with ODAC failed.
Please check $logfile for more details.
"@
    throw
}

finally {
    stop-transcript
}