$ErrorActionPreference = "Stop"

$scriptRoot = "C:\orainstall"

$install = "$scriptRoot\SetupODTforVS2015.exe"

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

    write-output "2. Create TNS_ADMIN if not exists..."
    if (!(Test-Path "C:\Oracle\Tnsadmin")) {
        new-item "C:\Oracle\Tnsadmin" -type directory
    }

    write-output "3. Backup Tnsadmin files if exists..."
    if (Test-Path "c:\Oracle\Tnsadmin\ldap.ora") {
        get-content "c:\Oracle\Tnsadmin\ldap.ora" 
    }

    if (Test-Path "c:\Oracle\Tnsadmin\sqlnet.ora") {
        get-content "c:\Oracle\Tnsadmin\sqlnet.ora"
    }

    write-output "4. Copy Tnsadmin files and replace if exists..."
    copy-item "$scriptRoot\Tnsadmin\sqlnet.ora" C:\Oracle\Tnsadmin\sqlnet.ora -force
    copy-item "$scriptRoot\Tnsadmin\ldap.ora" C:\Oracle\Tnsadmin\ldap.ora -force

    write-output "5. Set TNS_ADMIN system envrionment variable..."
    setx TNS_ADMIN C:\Oracle\Tnsadmin /M
    
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set TNS_ADMIN system envrionment variable."
    }

    write-output "6. Run $install..."
    $aList = @("/s","/f1`"$scriptRoot\SetupODTforVS2015.iss`"")
    $process = start-process -FilePath $install -ArgumentList $aList -NoNewWindow -Wait -PassThru        
    
    if ($process.ExitCode -ne 0) {
        throw "Installer Exit Code: $($process.ExitCode) for $install"
    }

  #  IFILE syntax not supported in Managed ODP.NET :( use symlinks instead
  #  write-output "7. Set sqlnet.ora and ldap.ora to IFILE to TNS_ADMIN"
  #  Set-Content  -Value "IFILE=C:\Oracle\Tnsadmin\sqlnet.ora" -Path "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin\sqlnet.ora" -Force
  #  Set-Content  -Value "IFILE=C:\Oracle\Tnsadmin\ldap.ora" -Path "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin\ldap.ora" -Force

    write-output "7. push-location  ${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin"
    push-location "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin"

    write-output "8. Remove .ora files"
    remove-item *.ora

    write-output "9. Create symlinks for sqlnet.ora and ldap.ora to TNS_ADMIN"
    Set-Content  -Value "IFILE=C:\Oracle\Tnsadmin\sqlnet.ora" -Path "${env:ProgramFiles(x86)}\Oracle Developer Tools for VS2015\network\admin\sqlnet.ora" -Force
    & cmd /c "mklink sqlnet.ora C:\Oracle\Tnsadmin\sqlnet.ora"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }

    & cmd /c "mklink ldap.ora C:\Oracle\Tnsadmin\ldap.ora"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed $$."
    }

    write-output "10. pop-location"
    pop-location

    write-output @"
Successfully Setup Software.
The installation of Oracle Developer Tools was successful.
Please check $logfile for more details.
"@
}

catch {
    $_ | Out-String
write-output @"
Failed Setup Software.
The installation of Oracle Developer Tools failed.
Please check $logfile for more details.
"@
    throw
}

finally {
    stop-transcript
}
