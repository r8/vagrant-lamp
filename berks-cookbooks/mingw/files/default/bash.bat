@echo off
set HOME=/home/%USERNAME%

IF "%MSYSTEM%"=="" (
  echo MSYSTEM is NOT defined
  exit
)

rem Ask MSYS to initialize with a minimal path by default.
rem This will put only the windows system paths into the msys path.
set MSYS2_PATH_TYPE=minimal

rem See /etc/profile - it should invoke post-install step 05-home-dir.post
rem which uses this environment variable to change directories.
set CHERE_INVOKING=1

%~dp0..\usr\bin\bash.exe -l %*
