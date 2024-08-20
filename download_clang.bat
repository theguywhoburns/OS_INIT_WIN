@ECHO OFF
setlocal enabledelayedexpansion
set CLANG_ARCH=i686-elf

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

echo You can use mingw64/bin/clang.exe, it can be used for cross compilation
if exist config.mk del config.mk
echo # %SEARCH_GCC% Makefile config > config.mk
echo # Built automatically using OS_INIT.bat >> config.mk
echo # Author https://github.com/theguywhoburns
echo CC  = %CD%/tools/mingw64/bin/clang.exe >> config.mk
echo CPP = %CD%/tools/mingw64/bin/clang++.exe >> config.mk
echo LD  = %CD%/tools/mingw64/bin/clang-linker-wrapper.exe >> config.mk
echo ASM = %CD%/tools/mingw64/bin/nasm.exe >> config.mk
echo CC_ARGS = -ffreestanding -nostdlib --arch %CLANG_ARCH% >> config.mk
echo ASM_ARGS = -f bin >> config.mk
echo LD_ARGS = >> config.mk