@echo off
REM Quick code generation for local development

call flutter packages get
if %ERRORLEVEL% NEQ 0 exit /b 1

REM Generate Hive adapters and other code
call flutter packages pub run build_runner build --delete-conflicting-outputs
if %ERRORLEVEL% NEQ 0 exit /b 1

echo Code generation completed.
pause
