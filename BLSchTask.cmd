@echo off
REM 1. If BitLocker TPM+Pin is there, no further action

cd c:\programdata\tools

for /f "tokens=1,2,3" %%i in ('manage-bde -status c:') ^
do if "%%i %%j %%k" == "TPM And PIN" (
REM echo %%i %%j %%k
goto :Exit
)

REM 2. If BitLocker TPM is there, show UI to ask end-user to setup TPM Pin


for /f "tokens=1,2,3" %%i in ('manage-bde -status c:') ^
do if "%%i %%j %%k" == "TPM  " (
setpin.cmd
goto :Exit
)


REM 3. If there is no TPM but TPM is enabled with password, no further action

for /f "tokens=1,2,3" %%i in ('manage-bde -status c:') ^
do if "%%i %%j %%k" == "Password  " (
goto :Exit
)

REM 4. If BitLocker is not enabled, show UI to enable BitLocker (it should cover TPM and non-TPM scenario)

for /f "tokens=1,2,3,4" %%i in ('manage-bde -status c:') ^
do if "%%k %%l" == "Fully Decrypted" (
startbl.cmd
goto :Exit
)

:Exit
