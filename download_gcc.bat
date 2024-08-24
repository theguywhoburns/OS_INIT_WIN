@ECHO OFF
setlocal enabledelayedexpansion
set GCC_VERSION=13.2.0
set GCC_ARCH=i686-elf
set "SUPPORTED_COMPILERS= i686-elf-gcc-13.2.0 x86_64-elf-gcc-13.2.0"

set i686-elf-gcc-13.2.0=https://github.com/lordmilko/i686-elf-tools/releases/download/13.2.0/i686-elf-tools-windows.zip
set x86_64-elf-gcc-13.2.0=https://github.com/lordmilko/i686-elf-tools/releases/download/13.2.0/x86_64-elf-tools-windows.zip

set "ZIP7_PATH=%CD%\tools\7zip"

:loop
if "%~1"=="" goto endloop
@REM TODO: notice a pattern here?
if "%~1"== "--compiler-version" (
	if "%~2" == "" (
		echo ERROR: you didn't specify the compiler version, defaulting to %GCC_VERSION%
	) else (
		set GCC_VERSION=%~2
	)
	shift
) else if "%~1"== "--compiler-arch" (
	if "%~2" == "" (
		echo ERROR: you didn't specify the compiler arch, defaulting to %GCC_ARCH%
	) else (
		set GCC_ARCH=%~2
	)
	shift
)

shift
goto loop
:endloop

set SEARCH_GCC=%GCC_ARCH%-gcc-%GCC_VERSION%
echo "%SUPPORTED_COMPILERS%" | findstr /C:"%SEARCH_GCC%" >nul
if errorlevel 1 (
  echo ERROR: Compiler "%SEARCH_GCC%" not found in SUPPORTED_COMPILERS
  exit /b 404
)

cd tools
if not exist arch\ mkdir arch\
cd arch
if not exist %GCC_ARCH%\ mkdir %GCC_ARCH%\
cd %GCC_ARCH%

if not exist %SEARCH_GCC%\ (
	echo Downloading %SEARCH_GCC%
	mkdir %SEARCH_GCC%\
	cd %SEARCH_GCC%
	call:download "!%SEARCH_GCC%!" "%SEARCH_GCC%.zip"
	call:unzip "%SEARCH_GCC%.zip"
	del "%SEARCH_GCC%.zip"
	cd ..
) else (
	echo %SEARCH_GCC% is already installed
)

cd ../../../
set REGENERATE_CONFIG_BAT=regenerate_config_%SEARCH_GCC%.bat
if exist %REGENERATE_CONFIG_BAT% del %REGENERATE_CONFIG_BAT%
echo @REM Automatically generated config re-generator > %REGENERATE_CONFIG_BAT%
echo @REM You are allowed to edit it but it's not nescesarry for it to work >>  %REGENERATE_CONFIG_BAT%
echo @REM to add a variable to config.mk call:addvar varname args >>  %REGENERATE_CONFIG_BAT%
echo set GCC_VERSION=%GCC_VERSION%>> %REGENERATE_CONFIG_BAT%
echo set GCC_ARCH=%GCC_ARCH%>> %REGENERATE_CONFIG_BAT%
echo set SEARCH_GCC=%%GCC_ARCH%%-gcc-%%GCC_VERSION%%>>  %REGENERATE_CONFIG_BAT%
echo if exist config.mk del config.mk >> %REGENERATE_CONFIG_BAT%
echo echo # Automatically generated %%SEARCH_GCC%% Makefile config by OS_INIT.bat ^> config.mk >>  %REGENERATE_CONFIG_BAT%
echo call:addcomment # Author https://github.com/theguywhoburns  >> %REGENERATE_CONFIG_BAT%
echo call:addcomment # To re-generate this config, call %REGENERATE_CONFIG_BAT%  >> %REGENERATE_CONFIG_BAT%
echo call:addvar CC  = %%CD%%/tools/arch/%%GCC_ARCH%%/%%SEARCH_GCC%%/bin/%%GCC_ARCH%%-gcc.exe  >>  %REGENERATE_CONFIG_BAT%
echo call:addvar CPP = %%CD%%/tools/arch/%%GCC_ARCH%%/%%SEARCH_GCC%%/bin/%%GCC_ARCH%%-g++.exe  >>  %REGENERATE_CONFIG_BAT%
echo call:addvar ASM = %%CD%%/tools/mingw64/bin/nasm.exe  >>  %REGENERATE_CONFIG_BAT%
echo call:addvar CC_ARGS = -ffreestanding -nostdlib >> %REGENERATE_CONFIG_BAT%
echo call:addvar CPP_ARGS = -ffreestanding -nostdlib >> %REGENERATE_CONFIG_BAT%
echo exit /b 0 >> %REGENERATE_CONFIG_BAT%
echo :addvar >>  %REGENERATE_CONFIG_BAT%
echo echo %%1 = %%* ^>^> config.mk >>  %REGENERATE_CONFIG_BAT%
echo exit /b 0 >>  %REGENERATE_CONFIG_BAT%
echo :addcomment >>  %REGENERATE_CONFIG_BAT%
echo echo %%* ^>^> config.mk >>  %REGENERATE_CONFIG_BAT%
echo exit /b 0 >>  %REGENERATE_CONFIG_BAT%
call %REGENERATE_CONFIG_BAT%
exit /b 0

@REM ==========================================================
@REM UTILITY SCRIPTS
@REM start the function with :<funcname> and end with exit /B 0
@REM ==========================================================

:download
if %2 EQU "" (
  echo ERROR: Must specify a URL and a filename
  exit /b 1
)
curl -sLo %2 %1
set ERR=errorlevel
exit /B %ERR%

:unzip
%ZIP7_PATH%\7z.exe x "%~1" -y > nul
exit /b 0

@REM ==========================================================
@REM END UTILITY SCRIPTS
@REM ==========================================================