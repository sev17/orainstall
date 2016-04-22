$ErrorActionPreference = "Stop"

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


    #OUI launches multiple processes, making trapping exit code difficult, so proceed on and check at end in step 10.
write-output @"
2. Run oui setup.exe using responseFile. 
   You can find the log of this install at C:\Program Files (x86)\Oracle\Inventory\logs..."
"@
 & "C:\oracle\product\12.1.0\client_1\oui\bin\setup.exe" -silent -waitforcompletion -nowait -deinstall 'DEINSTALL_LIST={"oracle.odac.client","12.1.0.2.0"}' 'REMOVE_HOMES={"C:\oracle\product\12.1.0\client_1"}'
    
    write-output "3. Check ExitCode of OUI..."
    if ($LASTEXITCODE -ne 0) {
        throw "Installer Exit Code: $LASTEXITCODE for C:\oracle\product\12.1.0\client_1\oui\bin\setup.exe"
    }

    write-output "4. Remove 12.1.0 Directory..."
    if (Test-Path "C:\Oracle\product\12.1.0") {
        remove-item -Recurse -Force C:\Oracle\product\12.1.0
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

