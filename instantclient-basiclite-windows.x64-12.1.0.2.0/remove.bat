@echo off
rem **********************************
rem Script remove.bat
rem Creation Date: 10/26/2015
rem Last Modified: 12/7/2015
rem Author: Chad Miller
rem ***********************************
rem Description: Removes Oracle instantclient_12_1
rem ***********************************

set logfile=%TEMP%\rjOraRemove%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log

@echo You can find the log of this install session at: %logfile%

>"%logfile%" (

	if exist C:\Oracle\product\12.1.0\xclient_1 (
		@echo WARN:  Existing instantclient_12_1 installation will be removed.
		rmdir C:\Oracle\product\12.1.0\xclient_1 /s /q 2>&1 || (
			@echo ERR:  rmdir C:\Oracle\product\12.1.0\xclient_1 failed.
			GOTO :ERR
		)
	) 

	rem GUI way to mode User Environment Variable "Start > Run > rundll32 sysdm.cpl,EditEnvironmentVariables"
	rem	Note: If you need to change Powershell code below, Copy Powershell code. Copy/Paste EncodedCommand after -EncodedCommand Param
	rem $EncodedCommand = {$ERRORACTION = "STOP"; if ((get-itemproperty -path HKCU:\Environment -Name Path -ErrorAction SilentlyContinue).Path -split ";" -notcontains "C:\Oracle\product\12.1.0\xclient_1") {exit}; $oldPath = [Environment]::GetEnvironmentVariable("Path","User");  Write-Output "INFO: OLDPATH=$oldPath"; if ($oldPath) {$newPath = $oldPath -replace "C:\\Oracle\\product\\12.1.0\\xclient_1;?","" }; try { [Environment]::SetEnvironmentVariable("Path", $newpath, "User") } catch { throw "C:\Oracle\product\12.1.0\xclient_1 failed to remove from path."}}
	rem [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($EncodedCommand)) | clip
		
	powershell -noprofile -Noninteractive -EncodedCommand JABFAFIAUgBPAFIAQQBDAFQASQBPAE4AIAA9ACAAIgBTAFQATwBQACIAOwAgAGkAZgAgACgAKABnAGUAdAAtAGkAdABlAG0AcAByAG8AcABlAHIAdAB5ACAALQBwAGEAdABoACAASABLAEMAVQA6AFwARQBuAHYAaQByAG8AbgBtAGUAbgB0ACAALQBOAGEAbQBlACAAUABhAHQAaAAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQApAC4AUABhAHQAaAAgAC0AcwBwAGwAaQB0ACAAIgA7ACIAIAAtAG4AbwB0AGMAbwBuAHQAYQBpAG4AcwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAMQAyAC4AMQAuADAAXAB4AGMAbABpAGUAbgB0AF8AMQAiACkAIAB7AGUAeABpAHQAfQA7ACAAJABvAGwAZABQAGEAdABoACAAPQAgAFsARQBuAHYAaQByAG8AbgBtAGUAbgB0AF0AOgA6AEcAZQB0AEUAbgB2AGkAcgBvAG4AbQBlAG4AdABWAGEAcgBpAGEAYgBsAGUAKAAiAFAAYQB0AGgAIgAsACIAVQBzAGUAcgAiACkAOwAgACAAVwByAGkAdABlAC0ATwB1AHQAcAB1AHQAIAAiAEkATgBGAE8AOgAgAE8ATABEAFAAQQBUAEgAPQAkAG8AbABkAFAAYQB0AGgAIgA7ACAAaQBmACAAKAAkAG8AbABkAFAAYQB0AGgAKQAgAHsAJABuAGUAdwBQAGEAdABoACAAPQAgACQAbwBsAGQAUABhAHQAaAAgAC0AcgBlAHAAbABhAGMAZQAgACIAQwA6AFwAXABPAHIAYQBjAGwAZQBcAFwAcAByAG8AZAB1AGMAdABcAFwAMQAyAC4AMQAuADAAXABcAHgAYwBsAGkAZQBuAHQAXwAxADsAPwAiACwAIgAiACAAfQA7ACAAdAByAHkAIAB7ACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoAUwBlAHQARQBuAHYAaQByAG8AbgBtAGUAbgB0AFYAYQByAGkAYQBiAGwAZQAoACIAUABhAHQAaAAiACwAIAAkAG4AZQB3AHAAYQB0AGgALAAgACIAVQBzAGUAcgAiACkAIAB9ACAAYwBhAHQAYwBoACAAewAgAHQAaAByAG8AdwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAMQAyAC4AMQAuADAAXAB4AGMAbABpAGUAbgB0AF8AMQAgAGYAYQBpAGwAZQBkACAAdABvACAAcgBlAG0AbwB2AGUAIABmAHIAbwBtACAAcABhAHQAaAAuACIAfQA= 2>&1 && (
		@echo INFO: C:\Oracle\product\12.1.0\xclient_1 removed from path.
	) || (
		@echo ERR: C:\Oracle\product\12.1.0\xclient_1 failed to remove from path.
		GOTO :ERR
	)

)

:SUCCESS
@echo Successfully Removed Software. >> "%logfile%"
@echo The removal of Oracle Client Instant was successful. &
@echo Please check '%logfile%' for more details. &
@echo Successfully Removed Software.
exit /b 0

:ERR
@echo Failed Remove Software. >> "%logfile%"
type '%logfile%'
@echo The removal of Oracle Client Instant failed. &
@echo Please check '%logfile%' for more details. &
@echo Failed Removal Software.
exit /b 1