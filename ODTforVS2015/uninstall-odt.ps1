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


    write-output "2. Get uninstallString from Registry."
    #$uninstall = gp HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ? {$_.DisplayName -eq "Oracle Developer Tools for Visual Studio 2015" -and $_.UninstallString -like "MsiExec*"}
    #$uninstallString = $uninstall.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $uninstall = gp HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ? {$_.DisplayName -eq "Oracle Developer Tools for Visual Studio 2015" -and $_.UninstallString -like "*setup*"}
    $uninstall.UninstallString -match '^(?<prog>"[^"]*")\s{1}(?<args>.*$)'
    $p = $matches.prog
    $a = $($matches.args -replace "  ", " ") -split " "
    write-output "3. Run Uninstall..."
    write-output "p: $p"
    write-output "a: $a"
    #$process = start-process -FilePath msiexec.exe -ArgumentList /X, $uninstallString, /quiet -Wait -PassThru
    $process = start-process -FilePath $p -ArgumentList $a -NoNewWindow -Wait -PassThru

    write-output "4. Check ExitCode uninstall."
    if ($process.ExitCode -ne 0) {
        throw "Uninstall Exit Code: $($process.ExitCode) for $($uninstall.DisplayName)"
    }
    
    write-output @"
Successfully Uninstall Software.
The uninstall of Oracle Developer Tools was successful.
Please check $logfile for more details.
"@
}

catch {
    $_ | Out-String
write-output @"
Failed Uninstall Software.
The uninstall of Oracle Developer Tools failed.
Please check $logfile for more details.
"@
    throw
}

finally {
    stop-transcript
}
