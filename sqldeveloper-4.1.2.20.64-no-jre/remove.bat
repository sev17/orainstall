@echo off
rem **********************************
rem Script remove.bat
rem Creation Date: 11/10/2015
rem Last Modified: 11/10/2015
rem Author: Chad Miller
rem ***********************************
rem Description: Removes sqldeveloper-4.1.2.20.64-no-jre
rem ***********************************

set logfile=%TEMP%\rjSqlDeveloperRemove%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log

@echo You can find the log of this install session at: %logfile%

>"%logfile%" (

	if exist C:\Oracle\product\sqldeveloper (
		@echo WARN:  Existing sqldeveloper installation will be removed.
		rmdir C:\Oracle\product\sqldeveloper /s /q 2>&1 || (
			@echo ERR:  rmdir C:\Oracle\product\sqldeveloper failed.
			GOTO :ERR
		)
	) 

	rem GUI way to mode User Environment Variable "Start > Run > rundll32 sysdm.cpl,EditEnvironmentVariables"
	rem	Note: If you need to change Powershell code below, Copy Powershell code. Copy/Paste EncodedCommand after -EncodedCommand Param
	rem $EncodedCommand = {$ERRORACTION = "STOP"; if ((get-itemproperty -path HKCU:\Environment -Name Path -ErrorAction SilentlyContinue).Path -split ";" -notcontains "C:\Oracle\product\sqldeveloper") {exit}; $oldPath = [Environment]::GetEnvironmentVariable("Path","User");  Write-Output "INFO: OLDPATH=$oldPath"; if ($oldPath) {$newPath = $oldPath -replace "C:\\Oracle\\product\\sqldeveloper;?","" }; try { [Environment]::SetEnvironmentVariable("Path", $newpath, "User") } catch { throw "C:\Oracle\product\sqldeveloper failed to remove from path."}}
	rem [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($EncodedCommand)) | clip
	
	powershell -noprofile -Noninteractive -EncodedCommand JABFAFIAUgBPAFIAQQBDAFQASQBPAE4AIAA9ACAAIgBTAFQATwBQACIAOwAgAGkAZgAgACgAKABnAGUAdAAtAGkAdABlAG0AcAByAG8AcABlAHIAdAB5ACAALQBwAGEAdABoACAASABLAEMAVQA6AFwARQBuAHYAaQByAG8AbgBtAGUAbgB0ACAALQBOAGEAbQBlACAAUABhAHQAaAAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQApAC4AUABhAHQAaAAgAC0AcwBwAGwAaQB0ACAAIgA7ACIAIAAtAG4AbwB0AGMAbwBuAHQAYQBpAG4AcwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAcwBxAGwAZABlAHYAZQBsAG8AcABlAHIAIgApACAAewBlAHgAaQB0AH0AOwAgACQAbwBsAGQAUABhAHQAaAAgAD0AIABbAEUAbgB2AGkAcgBvAG4AbQBlAG4AdABdADoAOgBHAGUAdABFAG4AdgBpAHIAbwBuAG0AZQBuAHQAVgBhAHIAaQBhAGIAbABlACgAIgBQAGEAdABoACIALAAiAFUAcwBlAHIAIgApADsAIAAgAFcAcgBpAHQAZQAtAE8AdQB0AHAAdQB0ACAAIgBJAE4ARgBPADoAIABPAEwARABQAEEAVABIAD0AJABvAGwAZABQAGEAdABoACIAOwAgAGkAZgAgACgAJABvAGwAZABQAGEAdABoACkAIAB7ACQAbgBlAHcAUABhAHQAaAAgAD0AIAAkAG8AbABkAFAAYQB0AGgAIAAtAHIAZQBwAGwAYQBjAGUAIAAiAEMAOgBcAFwATwByAGEAYwBsAGUAXABcAHAAcgBvAGQAdQBjAHQAXABcAHMAcQBsAGQAZQB2AGUAbABvAHAAZQByADsAPwAiACwAIgAiACAAfQA7ACAAdAByAHkAIAB7ACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoAUwBlAHQARQBuAHYAaQByAG8AbgBtAGUAbgB0AFYAYQByAGkAYQBiAGwAZQAoACIAUABhAHQAaAAiACwAIAAkAG4AZQB3AHAAYQB0AGgALAAgACIAVQBzAGUAcgAiACkAIAB9ACAAYwBhAHQAYwBoACAAewAgAHQAaAByAG8AdwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAcwBxAGwAZABlAHYAZQBsAG8AcABlAHIAIABmAGEAaQBsAGUAZAAgAHQAbwAgAHIAZQBtAG8AdgBlACAAZgByAG8AbQAgAHAAYQB0AGgALgAiAH0A 2>&1 && (
		@echo INFO: C:\Oracle\product\sqldeveloper removed from path.
	) || (
		@echo ERR: C:\Oracle\product\sqldeveloper failed to remove from path.
		GOTO :ERR
	)

	if exist "%USERPROFILE%\Desktop\sqldeveloper.lnk"  (
			@echo WARN:  Existing sqldeveloper.lnk will be removed.
			del "%USERPROFILE%\Desktop\sqldeveloper.lnk" 2>&1 || (
				@echo ERR:  del "%USERPROFILE%\Desktop\sqldeveloper.lnk"  failed.
				GOTO :ERR
			)
	) 


)

:SUCCESS
@echo Successfully Removed Software. >> "%logfile%"
@echo The removal of Oracle SQL Developer was successful. &
@echo Please check '%logfile%' for more details. &
@echo Successfully Removed Software.
exit /b 0

:ERR
@echo Failed Remove Software. >> "%logfile%"
type '%logfile%'
@echo The removal of Oracle SQL Developer failed. &
@echo Please check '%logfile%' for more details. &
@echo Failed Removal Software.
exit /b 1