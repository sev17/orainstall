$ErrorActionPreference = "Stop"

function Test-IsAdmin {
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

#check if admin
if (!(Test-IsAdmin)) {
    throw "Please run this script with admin priviliges"
}

#Get uninstall string from registry
$ht = @{}
gp HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
where {@('RJ TNSADMIN Installer ','RJ SQL Developer') -contains $($_.DisplayName)} | foreach {$ht.Add($_.DisplayName,$_.UninstallString)}

#run uninstalls
$ht.GetEnumerator() | foreach {
    $uninstall = $($_.Value) -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
    $uninstall = $uninstall.Trim()
    $process = start-process -FilePath msiexec.exe -ArgumentList /X, $uninstall, /quiet -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        throw "Uninstall Exit Code: $($process.ExitCode) for $($_.Name)"
    }
}

#check deinstall.bat exists
if (Test-Path "C:\Oracle\product\11.2.0\client_1\deinstall\deinstall.bat") {
    #Generate response file for silent deinstall
    & "C:\Oracle\product\11.2.0\client_1\deinstall\deinstall.bat" -silent -checkonly -o "$env:TEMP"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Deinstall Exit Code: $LASTEXITCODE for C:\Oracle\product\11.2.0\client_1\deinstall\deinstall.bat -silent -checkonly -o $env:TEMP"
    }
    
    $rsp = gci $env:TEMP\deinstall*.rsp | sort CreationTime | select -First 1 | foreach {$_.FullName}
    $args = @("-silent","-paramfile `"$rsp`"")

    #run deinstall.bat
    $process = start-process -FilePath "C:\Oracle\product\11.2.0\client_1\deinstall\deinstall.bat" -ArgumentList $args  -Wait -PassThru        

    if ($process.ExitCode -ne 0) {
        throw "Deinstall Exit Code: $($process.ExitCode) for C:\Oracle\product\11.2.0\client_1\deinstall\deinstall.bat  $args"
    }
}

#remove dir
if (Test-Path "C:\Oracle\product\11.2.0") {
    remove-item -Recurse -Force C:\Oracle\product\11.2.0
}

#remove start menu remove-item
if (Test-Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle - OraClient11g_home1_32bit") {
    remove-item -Recurse -Force "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Oracle - OraClient11g_home1_32bit"
}

#Remove C:\oracle\product\11.2.0\client_1\bin from SYSTEM Path Environment Variable
if ((get-itemproperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name Path -ErrorAction SilentlyContinue).Path -split ";" -contains "C:\oracle\product\11.2.0\client_1\bin") {
    
    $oldPath = [Environment]::GetEnvironmentVariable("Path","Machine")
    Write-Output "INFO: OLDPATH=$oldPath"

    if ($oldPath) {
        $newPath = $oldPath.Replace("C:\oracle\product\11.2.0\client_1\bin;","")
    } 

    try {
        if ($newPath) {
            [Environment]::SetEnvironmentVariable("Path", $newpath, "Machine")
        }
    }

    catch { throw "C:\oracle\product\11.2.0\client_1\bin failed to remove from path."}
}