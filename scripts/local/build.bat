@echo off
REM Windows Flutter build script with code generation

call flutter packages get
if %ERRORLEVEL% NEQ 0 exit /b 1

REM Generate Hive adapters
call flutter packages pub run build_runner build --delete-conflicting-outputs
if %ERRORLEVEL% NEQ 0 exit /b 1

call flutter analyze
call flutter build apk --release --no-obfuscate --no-shrink

pause
