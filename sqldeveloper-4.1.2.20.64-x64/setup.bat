@echo off
rem **********************************
rem Script setup.bat
rem Creation Date: 9/28/2015
rem Last Modified: 11/10/2015
rem Author: Chad Miller
rem ***********************************
rem Description: Installs sqldeveloper-4.1.2.20.64-x64
rem ***********************************

set logfile=%TEMP%\rjSqlDeveloperInstall%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log

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

	if exist C:\Oracle\product\sqldeveloper (
		@echo WARN:  Existing sqldeveloper installation will be removed.
		rmdir C:\Oracle\product\sqldeveloper /s /q 2>&1 || (
			@echo ERR:  rmdir C:\Oracle\product\sqldeveloper failed.
			GOTO :ERR
		)
	) 

	%~dp0unzip -q %~dp0sqldeveloper-4.1.2.20.64-x64.zip -d C:\Oracle\product 2>&1 && (
		@echo INFO: %~dp0sqldeveloper-4.1.2.20.64-x64.zip unzipped to C:\Oracle\product.
	) || (
		@echo ERR:  %~dp0unzip -q %~dp0sqldeveloper-4.1.2.20.64-x64.zip -d C:\Oracle\product failed.
		GOTO :ERR
	)

	rem GUI way to mode User Environment Variable "Start > Run > rundll32 sysdm.cpl,EditEnvironmentVariables"
	rem	Note: If you need to change Powershell code below, Copy Powershell code. Copy/Paste EncodedCommand after -EncodedCommand Param
	rem $EncodedCommand = {$ERRORACTION = "STOP"; if ((get-itemproperty -path HKCU:\Environment -Name Path -ErrorAction SilentlyContinue).Path -split ";" -contains "C:\Oracle\product\sqldeveloper") {exit}; $oldPath = [Environment]::GetEnvironmentVariable("Path","User");  Write-Output "INFO: OLDPATH=$oldPath"; if ($oldPath) {$newPath = "C:\Oracle\product\sqldeveloper;$oldPath"} else {$newpath = "C:\Oracle\product\sqldeveloper"}; try { [Environment]::SetEnvironmentVariable("Path", $newpath, "User") } catch { throw "C:\Oracle\product\sqldeveloper failed to add to path."}}
	rem [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($EncodedCommand)) | clip

	powershell -noprofile -Noninteractive -EncodedCommand JABFAFIAUgBPAFIAQQBDAFQASQBPAE4AIAA9ACAAIgBTAFQATwBQACIAOwAgAGkAZgAgACgAKABnAGUAdAAtAGkAdABlAG0AcAByAG8AcABlAHIAdAB5ACAALQBwAGEAdABoACAASABLAEMAVQA6AFwARQBuAHYAaQByAG8AbgBtAGUAbgB0ACAALQBOAGEAbQBlACAAUABhAHQAaAAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQApAC4AUABhAHQAaAAgAC0AcwBwAGwAaQB0ACAAIgA7ACIAIAAtAGMAbwBuAHQAYQBpAG4AcwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAcwBxAGwAZABlAHYAZQBsAG8AcABlAHIAIgApACAAewBlAHgAaQB0AH0AOwAgACQAbwBsAGQAUABhAHQAaAAgAD0AIABbAEUAbgB2AGkAcgBvAG4AbQBlAG4AdABdADoAOgBHAGUAdABFAG4AdgBpAHIAbwBuAG0AZQBuAHQAVgBhAHIAaQBhAGIAbABlACgAIgBQAGEAdABoACIALAAiAFUAcwBlAHIAIgApADsAIAAgAFcAcgBpAHQAZQAtAE8AdQB0AHAAdQB0ACAAIgBJAE4ARgBPADoAIABPAEwARABQAEEAVABIAD0AJABvAGwAZABQAGEAdABoACIAOwAgAGkAZgAgACgAJABvAGwAZABQAGEAdABoACkAIAB7ACQAbgBlAHcAUABhAHQAaAAgAD0AIAAiAEMAOgBcAE8AcgBhAGMAbABlAFwAcAByAG8AZAB1AGMAdABcAHMAcQBsAGQAZQB2AGUAbABvAHAAZQByADsAJABvAGwAZABQAGEAdABoACIAfQAgAGUAbABzAGUAIAB7ACQAbgBlAHcAcABhAHQAaAAgAD0AIAAiAEMAOgBcAE8AcgBhAGMAbABlAFwAcAByAG8AZAB1AGMAdABcAHMAcQBsAGQAZQB2AGUAbABvAHAAZQByACIAfQA7ACAAdAByAHkAIAB7ACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoAUwBlAHQARQBuAHYAaQByAG8AbgBtAGUAbgB0AFYAYQByAGkAYQBiAGwAZQAoACIAUABhAHQAaAAiACwAIAAkAG4AZQB3AHAAYQB0AGgALAAgACIAVQBzAGUAcgAiACkAIAB9ACAAYwBhAHQAYwBoACAAewAgAHQAaAByAG8AdwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAcwBxAGwAZABlAHYAZQBsAG8AcABlAHIAIABmAGEAaQBsAGUAZAAgAHQAbwAgAGEAZABkACAAdABvACAAcABhAHQAaAAuACIAfQA= 2>&1 && (
		@echo INFO: C:\Oracle\product\sqldeveloper added to path.
	) || (
		@echo ERR: C:\Oracle\product\sqldeveloper failed to add to path.
		GOTO :ERR
	)

	powershell -noprofile -Noninteractive -Command "$ERRORACTION = 'STOP';try {$s=(New-Object -COM WScript.Shell).CreateShortcut('%USERPROFILE%\desktop\sqldeveloper.lnk');$s.TargetPath='C:\Oracle\product\sqldeveloper\sqldeveloper.exe';$s.Save()} catch {throw $_}"  2>&1 && (
		@echo INFO: C:\Oracle\product\sqldeveloper\sqldeveloper.exe desktop shortcut created.
	) || (
		@echo ERR: C:\Oracle\product\sqldeveloper\sqldeveloper.exe desktop shortcut creation failed.
		GOTO :ERR
	)

)

:SUCCESS
@echo Successfully Setup Software. >> "%logfile%"
@echo The installation of Oracle SQL Developer was successful. &
@echo Please check '%logfile%' for more details. &
@echo Successfully Setup Software.
exit /b 0

:ERR
@echo Failed Setup Software. >> "%logfile%"
type '%logfile%'
@echo The installation of Oracle SQL Developer failed. &
@echo Please check '%logfile%' for more details. &
@echo Failed Setup Software.
exit /b 1