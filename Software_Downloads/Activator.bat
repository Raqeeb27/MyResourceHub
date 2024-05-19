@echo off
echo Activating Windows...

echo Installing product key...
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
if %errorlevel% neq 0 (
    echo Failed to install product key. Exiting...
    exit /b %errorlevel%
)

echo Setting KMS server...
slmgr /skms kms8.msguides.com
if %errorlevel% neq 0 (
    echo Failed to set KMS server. Exiting...
    exit /b %errorlevel%
)

echo Activating Windows now...

REM Attempt activation up to 3 times
set /a attempt=0
:activate
slmgr /ato
if %errorlevel% neq 0 (
    echo Activation attempt %attempt% failed.
    set /a attempt+=1
    if %attempt% lss 3 (
        timeout /t 10 >nul
        goto activate
    ) else (
        echo Failed to activate Windows after 3 attempts. Exiting...
        exit /b %errorlevel%
    )
)

echo Windows activated successfully!

choice /M "Windows is activated. Do you want to restart now?"
if %errorlevel% equ 1 (
    echo Restarting the system...
    shutdown /r /t 10 /f /d p:4:1 /c "Restarting to complete Windows activation."
) else (
    echo Exiting without restart.
)
