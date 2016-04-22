@echo off
rem **********************************
rem Script setup.bat
rem Creation Date: 9/28/2015
rem Last Modified: 12/7/2015
rem Author: Chad Miller
rem ***********************************
rem Description: Installs Oracle instantclient_12_1
rem ***********************************

set logfile=%TEMP%\rjOraInstall%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log

@echo You can find the log of this install session at: %logfile%

>"%logfile%" (

	rem Installer for x64
	if %PROCESSOR_ARCHITECTURE%==x86 (
		@echo ERR: Unsupported architecture %PROCESSOR_ARCHITECTURE%!
		GOTO :ERR
	)

	if not exist C:\Oracle\product mkdir C:\Oracle\product  2>&1 && (
		@echo INFO: Directory C:\Oracle\product created.
	) || (
		@echo ERR:  mkdir C:\Oracle\product failed.
		GOTO :ERR
	)
	if not exist C:\Oracle\Tnsadmin mkdir C:\Oracle\Tnsadmin 2>&1 && (
		@echo INFO: Directory C:\Oracle\Tnsadmin created.
	) || (
		@echo ERR:  mkdir C:\Oracle\Tnsadmin failed.
		GOTO :ERR
	)

	rem backup existing ldap.ora to install logfile
	if exist C:\Oracle\Tnsadmin\ldap.ora (
		@echo INFO: Existing ldap.ora.
		type C:\Oracle\Tnsadmin\ldap.ora 2>&1 
	) || (
		@echo ERR:  type C:\Oracle\Tnsadmin\ldap.ora failed.
		GOTO :ERR
	)

	copy /y %~dp0Tnsadmin\ldap.ora C:\Oracle\Tnsadmin\ldap.ora 2>&1 && (
		@echo INFO: copy %~dp0Tnsadmin\ldap.ora successful.
	) || (
		@echo ERR:  copy %~dp0Tnsadmin\ldap.ora failed.
		GOTO :ERR
	)

	rem backup existing sqlnet.ora to install logfile
	if exist C:\Oracle\Tnsadmin\sqlnet.ora (
		@echo INFO: Existing sqlnet.ora.
		type C:\Oracle\Tnsadmin\sqlnet.ora 2>&1 
	) || (
		@echo ERR:  type C:\Oracle\Tnsadmin\sqlnet.ora failed.
		GOTO :ERR
	)

	copy /y %~dp0Tnsadmin\sqlnet.ora C:\Oracle\Tnsadmin\sqlnet.ora 2>&1 && (
		@echo INFO: copy %~dp0Tnsadmin\sqlnet.ora successful.
	) || (
		@echo ERR:  copy %~dp0Tnsadmin\sqlnet.ora failed.
		GOTO :ERR
	)

	if exist C:\Oracle\product\12.1.0\xclient_1 (
		@echo WARN:  Existing instantclient_12_1 installation will be removed.
		rmdir C:\Oracle\product\12.1.0\xclient_1 /s /q 2>&1 || (
			@echo ERR:  rmdir C:\Oracle\product\12.1.0\xclient_1 failed.
			GOTO :ERR
		)
	)

	if not exist C:\Oracle\product\12.1.0\xclient_1 mkdir C:\Oracle\product\12.1.0\xclient_1 2>&1 && (
		@echo INFO: Directory C:\Oracle\product\12.1.0\xclient_1 created.
	) || (
		@echo ERR:  mkdir C:\Oracle\product\12.1.0\xclient_1 failed.
		GOTO :ERR
	)

	%~dp0unzip -o -q %~dp0instantclient-basiclite-windows.x64-12.1.0.2.0.zip 2>&1 && (
		@echo INFO: %~dp0instantclient-basiclite-windows.x64-12.1.0.2.0.zip unzipped to %~dp0.
	) || (
		@echo ERR:  %~dp0unzip -o -q %~dp0instantclient-basiclite-windows.x64-12.1.0.2.0.zip failed.
		GOTO :ERR
	)

	xcopy instantclient_12_1 C:\Oracle\product\12.1.0\xclient_1 /E /F /R /Y 2>&1 && (
		@echo INFO: Copied instantclient_12_1 files to C:\Oracle\product\12.1.0\xclient_1.
	) || (
		@echo ERR:  mkdir instantclient_12_1 files to C:\Oracle\product\12.1.0\xclient_1 copy failed.
		GOTO :ERR
	)

	setx TNS_ADMIN C:\Oracle\Tnsadmin 2>&1 && (
		@echo INFO: User Environment Variable TNS_ADMIN set to C:\Oracle\Tnsadmin.
	) || (
		@echo ERR:  setx TNS_ADMIN C:\Oracle\Tnsadmin.
		GOTO :ERR
	)

	rem GUI way to mode User Environment Variable "Start > Run > rundll32 sysdm.cpl,EditEnvironmentVariables"
	rem	Note: If you need to change Powershell code below, Copy Powershell code. Copy/Paste EncodedCommand after -EncodedCommand Param
	rem	$EncodedCommand = {$ERRORACTION = "STOP"; if ((get-itemproperty -path HKCU:\Environment -Name Path -ErrorAction SilentlyContinue).Path -split ";" -contains "C:\Oracle\product\12.1.0\xclient_1") {exit}; $oldPath = [Environment]::GetEnvironmentVariable("Path","User");  Write-Output "INFO: OLDPATH=$oldPath"; if ($oldPath) {$newPath = "C:\Oracle\product\12.1.0\xclient_1;$oldPath"} else {$newpath = "C:\Oracle\product\12.1.0\xclient_1"}; try { [Environment]::SetEnvironmentVariable("Path", $newpath, "User") } catch { throw "C:\Oracle\product\12.1.0\xclient_1 failed to add to path."}}
	rem [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($EncodedCommand)) | clip
	
	powershell -noprofile -Noninteractive -EncodedCommand JABFAFIAUgBPAFIAQQBDAFQASQBPAE4AIAA9ACAAIgBTAFQATwBQACIAOwAgAGkAZgAgACgAKABnAGUAdAAtAGkAdABlAG0AcAByAG8AcABlAHIAdAB5ACAALQBwAGEAdABoACAASABLAEMAVQA6AFwARQBuAHYAaQByAG8AbgBtAGUAbgB0ACAALQBOAGEAbQBlACAAUABhAHQAaAAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQApAC4AUABhAHQAaAAgAC0AcwBwAGwAaQB0ACAAIgA7ACIAIAAtAGMAbwBuAHQAYQBpAG4AcwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAMQAyAC4AMQAuADAAXAB4AGMAbABpAGUAbgB0AF8AMQAiACkAIAB7AGUAeABpAHQAfQA7ACAAJABvAGwAZABQAGEAdABoACAAPQAgAFsARQBuAHYAaQByAG8AbgBtAGUAbgB0AF0AOgA6AEcAZQB0AEUAbgB2AGkAcgBvAG4AbQBlAG4AdABWAGEAcgBpAGEAYgBsAGUAKAAiAFAAYQB0AGgAIgAsACIAVQBzAGUAcgAiACkAOwAgACAAVwByAGkAdABlAC0ATwB1AHQAcAB1AHQAIAAiAEkATgBGAE8AOgAgAE8ATABEAFAAQQBUAEgAPQAkAG8AbABkAFAAYQB0AGgAIgA7ACAAaQBmACAAKAAkAG8AbABkAFAAYQB0AGgAKQAgAHsAJABuAGUAdwBQAGEAdABoACAAPQAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAMQAyAC4AMQAuADAAXAB4AGMAbABpAGUAbgB0AF8AMQA7ACQAbwBsAGQAUABhAHQAaAAiAH0AIABlAGwAcwBlACAAewAkAG4AZQB3AHAAYQB0AGgAIAA9ACAAIgBDADoAXABPAHIAYQBjAGwAZQBcAHAAcgBvAGQAdQBjAHQAXAAxADIALgAxAC4AMABcAHgAYwBsAGkAZQBuAHQAXwAxACIAfQA7ACAAdAByAHkAIAB7ACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoAUwBlAHQARQBuAHYAaQByAG8AbgBtAGUAbgB0AFYAYQByAGkAYQBiAGwAZQAoACIAUABhAHQAaAAiACwAIAAkAG4AZQB3AHAAYQB0AGgALAAgACIAVQBzAGUAcgAiACkAIAB9ACAAYwBhAHQAYwBoACAAewAgAHQAaAByAG8AdwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAMQAyAC4AMQAuADAAXAB4AGMAbABpAGUAbgB0AF8AMQAgAGYAYQBpAGwAZQBkACAAdABvACAAYQBkAGQAIAB0AG8AIABwAGEAdABoAC4AIgB9AA== 2>&1 && (
		@echo INFO: C:\Oracle\product\12.1.0\xclient_1 added to path.
	) || (
		@echo ERR: C:\Oracle\product\12.1.0\xclient_1 failed to add to path.
		GOTO :ERR
	)

)

:SUCCESS
@echo Successfully Setup Software. >> "%logfile%"
@echo The installation of Oracle Client Instant was successful. &
@echo Please check '%logfile%' for more details. &
@echo Successfully Setup Software.
exit /b 0

:ERR
@echo Failed Setup Software. >> "%logfile%"
type '%logfile%'
@echo The installation of Oracle Client Instant failed. &
@echo Please check '%logfile%' for more details. &
@echo Failed Setup Software.
exit /b 1