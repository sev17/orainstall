@echo off
rem **********************************
rem Script remove.bat
rem Creation Date: 10/26/2015
rem Last Modified: 12/7/2015
rem Author: Chad Miller
rem ***********************************
rem Description: Removes Oracle instantclient_12_1 x86
rem ***********************************

set logfile=%TEMP%\rjOraRemovex86%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.log

@echo You can find the log of this install session at: %logfile%

>"%logfile%" (

	if exist C:\Oracle\product\x86\12.1.0\xclient_1 (
		@echo WARN:  Existing x86\instantclient_12_1 installation will be removed.
		rmdir C:\Oracle\product\x86\12.1.0\xclient_1 /s /q 2>&1 || (
			@echo ERR:  rmdir C:\Oracle\product\x86\12.1.0\xclient_1 failed.
			GOTO :ERR
		)
	) 

	rem GUI way to mode User Environment Variable "Start > Run > rundll32 sysdm.cpl,EditEnvironmentVariables"
	rem	Note: If you need to change Powershell code below, Copy Powershell code. Copy/Paste EncodedCommand after -EncodedCommand Param
	rem $EncodedCommand = {$ERRORACTION = "STOP"; if ((get-itemproperty -path HKCU:\Environment -Name Path -ErrorAction SilentlyContinue).Path -split ";" -notcontains "C:\Oracle\product\x86\12.1.0\xclient_1") {exit}; $oldPath = [Environment]::GetEnvironmentVariable("Path","User");  Write-Output "INFO: OLDPATH=$oldPath"; if ($oldPath) {$newPath = $oldPath -replace "C:\\Oracle\\product\\x86\\12.1.0\\xclient_1;?","" }; try { [Environment]::SetEnvironmentVariable("Path", $newpath, "User") } catch { throw "C:\Oracle\product\x86\12.1.0\xclient_1 failed to remove from path."}}
	rem [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($EncodedCommand)) | clip
	
	powershell -noprofile -Noninteractive -EncodedCommand JABFAFIAUgBPAFIAQQBDAFQASQBPAE4AIAA9ACAAIgBTAFQATwBQACIAOwAgAGkAZgAgACgAKABnAGUAdAAtAGkAdABlAG0AcAByAG8AcABlAHIAdAB5ACAALQBwAGEAdABoACAASABLAEMAVQA6AFwARQBuAHYAaQByAG8AbgBtAGUAbgB0ACAALQBOAGEAbQBlACAAUABhAHQAaAAgAC0ARQByAHIAbwByAEEAYwB0AGkAbwBuACAAUwBpAGwAZQBuAHQAbAB5AEMAbwBuAHQAaQBuAHUAZQApAC4AUABhAHQAaAAgAC0AcwBwAGwAaQB0ACAAIgA7ACIAIAAtAG4AbwB0AGMAbwBuAHQAYQBpAG4AcwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAeAA4ADYAXAAxADIALgAxAC4AMABcAHgAYwBsAGkAZQBuAHQAXwAxACIAKQAgAHsAZQB4AGkAdAB9ADsAIAAkAG8AbABkAFAAYQB0AGgAIAA9ACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoARwBlAHQARQBuAHYAaQByAG8AbgBtAGUAbgB0AFYAYQByAGkAYQBiAGwAZQAoACIAUABhAHQAaAAiACwAIgBVAHMAZQByACIAKQA7ACAAIABXAHIAaQB0AGUALQBPAHUAdABwAHUAdAAgACIASQBOAEYATwA6ACAATwBMAEQAUABBAFQASAA9ACQAbwBsAGQAUABhAHQAaAAiADsAIABpAGYAIAAoACQAbwBsAGQAUABhAHQAaAApACAAewAkAG4AZQB3AFAAYQB0AGgAIAA9ACAAJABvAGwAZABQAGEAdABoACAALQByAGUAcABsAGEAYwBlACAAIgBDADoAXABcAE8AcgBhAGMAbABlAFwAXABwAHIAbwBkAHUAYwB0AFwAXAB4ADgANgBcAFwAMQAyAC4AMQAuADAAXABcAHgAYwBsAGkAZQBuAHQAXwAxADsAPwAiACwAIgAiACAAfQA7ACAAdAByAHkAIAB7ACAAWwBFAG4AdgBpAHIAbwBuAG0AZQBuAHQAXQA6ADoAUwBlAHQARQBuAHYAaQByAG8AbgBtAGUAbgB0AFYAYQByAGkAYQBiAGwAZQAoACIAUABhAHQAaAAiACwAIAAkAG4AZQB3AHAAYQB0AGgALAAgACIAVQBzAGUAcgAiACkAIAB9ACAAYwBhAHQAYwBoACAAewAgAHQAaAByAG8AdwAgACIAQwA6AFwATwByAGEAYwBsAGUAXABwAHIAbwBkAHUAYwB0AFwAeAA4ADYAXAAxADIALgAxAC4AMABcAHgAYwBsAGkAZQBuAHQAXwAxACAAZgBhAGkAbABlAGQAIAB0AG8AIAByAGUAbQBvAHYAZQAgAGYAcgBvAG0AIABwAGEAdABoAC4AIgB9AA== 2>&1 && (
		@echo INFO: C:\Oracle\product\x86\12.1.0\xclient_1 removed from path.
	) || (
		@echo ERR: C:\Oracle\product\x86\12.1.0\xclient_1 failed to remove from path.
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