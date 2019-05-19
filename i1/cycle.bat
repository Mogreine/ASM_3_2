@echo off

..\ta\BIN\TASM.exe /m3 mlab1.asm
if ERRORLEVEL 1 goto mlab1_err
..\ta\BIN\TASM.exe /m3 mlab1l.asm
if ERRORLEVEL 1 goto mlab1l_err
..\ta\BIN\TASM.exe /m3 lib.asm
if ERRORLEVEL 1 goto lib_err
..\ta\BIN\TASM.exe /m3 lab1.asm
if ERRORLEVEL 1 goto lab1_err

..\ta\BIN\TLINK.exe /3 mlab1+mlab1l+lab1+lib
if ERRORLEVEL 1 goto link_err

echo No errors.
goto end

:mlab1_err
echo mlab1l wasn't compiled.
notepad mlab1.asm
goto end

:mlab1l_err
echo mlab1l wasn't compiled.
notepad mlab1l.asm
goto end

:lib_err
echo lib wasn't compiled.
notepad lib.asm
goto end

:lab1_err
echo lab1 wasn't compiled.
notepad lab1.asm
goto end

:link_err
echo Linking is failed.
goto end

:end
