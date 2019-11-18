@echo off
set pth=C:\masm32\bin
%pth%\ml /c %1.asm
%pth%\link16 /tiny %1.obj, %1.com,,,,
echo Dump -----
echo ----------
type sn.map
echo ----------
