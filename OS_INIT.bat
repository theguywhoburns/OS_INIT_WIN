@ECHO OFF
@REM THIS REPRESENTS AVAILABLE FOR INSTALL COMPILER_SCRIPTS
@REM SO THIS FILE WILL WGET IT FROM THE REPOSITORY
@REM EXAMPLE: if PREFERRED_COMPILER=gcc then it'll
@REM call:download https://github.com/theguywhoburns/OS_INIT_WIN/download_%PREFERRED_COMPILER%.bat

setlocal

REM Define the AVAILABLE_COMPILERS list (example)
set "AVAILABLE_COMPILERS=gcc clang"

REM Initialize variables
set "INTERACTIVE=1"
set "CUSTOM_COMPILER_SCRIPT_URL="
set "COMPILER=gcc"
set "VERSION=1"

goto:ChekUpdate 
:EndChekUpdate

echo OS_INIT, a single file os development environment for initializer

REM Loop through all arguments using FOR loop
:loop
if "%~1"=="" goto endloop

REM Check if the argument is --quick
if "%~1"=="--quick" (
  set "INTERACTIVE=0"
) else if "%~1"=="--help" (
  echo Help message goes here.
  exit /b 0
) else if "%~1"=="-h" (
  echo Help message goes here.
  exit /b 0
) else if "%~1"=="--custom-compiler-installer" (
  if "%~2"=="" (
    echo ERROR: missing url for --custom-compiler-installer
  )
  set "CUSTOM_COMPILER_SCRIPT_URL=%~2"
  shift
) else if "%~1"=="--compiler" (
  if "%~2"=="" (
    echo ERROR: missing compiler
  )
  set COMPILER=%~2
  shift
) else (
  echo ERROR: unknown arg %~1, exiting
  exit /b 1
)

shift
goto loop
:endloop

REM Check if the compiler is in AVAILABLE_COMPILERS
echo "%AVAILABLE_COMPILERS%" | findstr /C:"%COMPILER%" >nul
if errorlevel 1 (
  REM Compiler not found in AVAILABLE_COMPILERS, check if CUSTOM_COMPILER_SCRIPT_URL is set
  if "%CUSTOM_COMPILER_SCRIPT_URL%"=="" (
    echo Error: Compiler "%COMPILER%" not found in AVAILABLE_COMPILERS and no custom compiler installer URL provided.
    exit /b 1
  )
)

if %INTERACTIVE% == 0 (
  goto main
)

echo Available compilers: %AVAILABLE_COMPILERS%
set /p COMPILER= "compiler[%COMPILER%]: "

echo "%AVAILABLE_COMPILERS%" | findstr /C:"%COMPILER%" >nul
if errorlevel 1 (
  REM Compiler not found in AVAILABLE_COMPILERS, check if CUSTOM_COMPILER_SCRIPT_URL is set
  if "%CUSTOM_COMPILER_SCRIPT_URL%"=="" (
    echo Error: Compiler "%COMPILER%" not found in AVAILABLE_COMPILERS and no custom compiler installer URL provided.
    exit /b 1
  )
)

:main
echo Curent args:
echo INTERACTIVE                = %INTERACTIVE%
echo AVAILABLE_COMPILERS        = %AVAILABLE_COMPILERS%
echo COMPILER                   = %COMPILER%
echo CUSTOM_COMPILER_SCRIPT_URL = %CUSTOM_COMPILER_SCRIPT_URL%

if not exist tools\ mkdir tools
cd tools
echo Downloading mingw64 tools to compile the %COMPILER%
if not exist mingw64\ (
  call:download "https://github.com/brechtsanders/winlibs_mingw/releases/download/14.2.0posix-18.1.8-12.0.0-ucrt-r1/winlibs-x86_64-posix-seh-gcc-14.2.0-llvm-18.1.8-mingw-w64ucrt-12.0.0-r1.zip" "mingw64"
  call:unzip "mingw64"
  del mingw64.zip 
  echo Done!
) else (
  echo Seems like mingw64 is already downloaded, skipping!
)

@REM DOWNLOADING THE EMULATOR
@REM TODO: MAKE 2 EMULATORS AVAILABLE FOR INSTALL, BOCHS AND QEMU, RN ONLU QEMU
echo Downloading qemu
if not exist "qemu/" (
  call:download "http://lassauge.free.fr/qemu/release/Qemu-0.15.1-windows-Medium.zip" "qemu.zip"
  call:unzip "qemu.zip"
  ren "Qemu-windows-0.15.1" "qemu"
  del "qemu.zip"
  echo Done!
) else (
  echo Seems like qemu is already installed, skipping...
)

@REM SET THE COMPILER URL TO THE DEFAULT ONE IF THE %CUSTOM_COMPILER_SCRIPT_URL% IS NOT SET
if "%CUSTOM_COMPILER_SCRIPT_URL%" EQU "" (
  set CUSTOM_COMPILER_SCRIPT_URL=https://raw.githubusercontent.com/theguywhoburns/OS_INIT_WIN/main
)

cd ..
echo Downloading "download_%COMPILER%.bat"
call:download "%CUSTOM_COMPILER_SCRIPT_URL%/download_%COMPILER%.bat" "download_%COMPILER%.bat"
if not exist "download_%COMPILER%.bat" (
  echo ERROR: Failed to download "%CUSTOM_COMPILER_SCRIPT_URL%/download_%COMPILER%.bat" 
  echo ERROR: If you didn't specify the Custom compiler script url please contact me or try to run the script again
  echo ERROR: Else it's your problem
  exit /B 1
)
echo Success!
echo Launching "download_%COMPILER%.bat"
call "download_%COMPILER%.bat" %*

@REM end my suffering
exit /B 0

@REM ==========================================================
@REM UTILITY SCRIPTS
@REM start the function with :<funcname> and end with exit /B 0
@REM ==========================================================

:download <url> <filename>
if %2 EQU "" (
  echo ERROR: Must specify a URL and a filename
  exit /b 1
)
curl -sLo %2 %1
set ERR=errorlevel
exit /B %ERR%
:unzip <zipfile>
7z x "%~1" -y > nul
exit /b 0

:ChekUpdate
call:download "https://raw.githubusercontent.com/theguywhoburns/OS_INIT_WIN/main/OS_INIT_VERSION.txt" "OS_INIT_VERSION.txt"
set /p GIT_VERSION=< ./OS_INIT_VERSION.txt
echo %GIT_VERSION%
pause
if "%GIT_VERSION%" GTR "%VERSION%" (
  call:download "https://raw.githubusercontent.com/theguywhoburns/OS_INIT_WIN/main/OS_INIT.bat" "OS_INIT.bat"
  pause
  call OS_INIT.bat %*
  exit /b errorlevel
) else (
  pause
  goto:EndChekUpdate
)
@REM ==========================================================
@REM END UTILITY SCRIPTS
@REM ==========================================================