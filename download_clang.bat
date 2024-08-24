@ECHO OFF
setlocal enabledelayedexpansion
set CLANG_ARCH=i686-elf

set "ZIP7_PATH=%CD%\tools\7zip"

:loop
if "%~1"=="" goto endloop
@REM TODO: notice a pattern here?
if "%~1"== "--compiler-version" (
	if "%~2" == "" (
		echo ERROR: you didn't specify the compiler version
	) else (
		echo ERROR: TODO
	)
	shift
) else if "%~1"== "--compiler-arch" (
	if "%~2" == "" (
		echo ERROR: you didn't specify the compiler arch, defaulting to %CLANG_ARCH%
	) else (
		set CLANG_ARCH=%~2
	)
	shift
)

shift
goto loop
:endloop

set REGENERATE_CONFIG_BAT=regenerate_config_clang_%CLANG_ARCH%.bat
if exist %REGENERATE_CONFIG_BAT% del %REGENERATE_CONFIG_BAT%
echo @REM Automatically generated config re-generator > %REGENERATE_CONFIG_BAT%
echo @REM You are allowed to edit it but it's not nescesarry for it to work >>  %REGENERATE_CONFIG_BAT%
echo @REM to add a variable to config.mk call:addvar varname args >>  %REGENERATE_CONFIG_BAT%
echo set CLANG_ARCH=%CLANG_ARCH%>> %REGENERATE_CONFIG_BAT%
echo set SEARCH_CLANG=clang target %%CLANG_ARCH%%>>  %REGENERATE_CONFIG_BAT%
echo if exist config.mk del config.mk >> %REGENERATE_CONFIG_BAT%
echo echo # Automatically generated %%SEARCH_CLANG%% Makefile config by OS_INIT.bat ^> config.mk >>  %REGENERATE_CONFIG_BAT%
echo call:addcomment # Author https://github.com/theguywhoburns  >> %REGENERATE_CONFIG_BAT%
echo call:addcomment # To re-generate this config, call %REGENERATE_CONFIG_BAT%  >> %REGENERATE_CONFIG_BAT%
echo call:addvar CC  = %%CD%%/tools/mingw64/bin/clang.exe  >>  %REGENERATE_CONFIG_BAT%
echo call:addvar CPP = %%CD%%/tools/mingw64/bin/clang++.exe  >>  %REGENERATE_CONFIG_BAT%
echo call:addvar ASM = %%CD%%/tools/mingw64/bin/nasm.exe  >>  %REGENERATE_CONFIG_BAT%
echo call:addvar CC_ARGS = -ffreestanding -nostdlib --target %CLANG_ARCH% >> %REGENERATE_CONFIG_BAT%
echo call:addvar CPP_ARGS = -ffreestanding -nostdlib --target %CLANG_ARCH% >> %REGENERATE_CONFIG_BAT%
echo exit /b 0 >> %REGENERATE_CONFIG_BAT%
echo :addvar >>  %REGENERATE_CONFIG_BAT%
echo echo %%1 = %%* ^>^> config.mk >>  %REGENERATE_CONFIG_BAT%
echo exit /b 0 >>  %REGENERATE_CONFIG_BAT%
echo :addcomment >>  %REGENERATE_CONFIG_BAT%
echo echo %%* ^>^> config.mk >>  %REGENERATE_CONFIG_BAT%
echo exit /b 0 >>  %REGENERATE_CONFIG_BAT%
call %REGENERATE_CONFIG_BAT%
exit /b 0