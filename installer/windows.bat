@ECHO OFF
SETLOCAL

SET "SCRIPT_DIR=%~dp0"
SET "ROOT_DIR=%SCRIPT_DIR%.."
SET "BUILD_DIR=%ROOT_DIR%\build"
SET "DIST_DIR=%ROOT_DIR%\dist"
SET "PLUGIN_NAME=ScreamLite"

IF NOT EXIST "%DIST_DIR%" mkdir "%DIST_DIR%"

SET "VERSION="
FOR /F "tokens=1,2" %%a IN ('findstr /R /C:"^[ ]*VERSION [0-9]" "%ROOT_DIR%\CMakeLists.txt"') DO (
    IF NOT DEFINED VERSION SET "VERSION=%%b"
)

IF NOT DEFINED VERSION (
    ECHO Failed to determine version from CMakeLists.txt
    EXIT /B 1
)

ECHO Building Scream Lite %VERSION%

CALL "%ROOT_DIR%\shaders.bat"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

IF EXIST "%BUILD_DIR%" RMDIR /S /Q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"

CALL cmake --no-warn-unused-cli ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DSCREAM_LITE_BUILD_STANDALONE=OFF ^
    -S"%ROOT_DIR%" ^
    -B"%BUILD_DIR%" ^
    -G Ninja
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL cmake --build "%BUILD_DIR%" --config Release --target all --
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL ISCC.exe /DMyVersion=%VERSION% "%SCRIPT_DIR%_windows.iss"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

ECHO Installer: %DIST_DIR%\%PLUGIN_NAME%_v%VERSION%.exe
ENDLOCAL
