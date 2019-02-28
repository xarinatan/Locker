@echo off
if not exist ".lock" goto main
SET /P AREYOUSURE=There appears to be a lock file. Would you like to issue a kill request?[y/N]
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
echo %username%@%computername% wants to open this program on Windows > .kill
echo Kill request issued, waiting until .lock disappears (check your sync client).
:waitloop
<nul set /p =.
ping 127.0.0.1 -n 2 > nul
if exist .lock ( goto waitloop )
else ( 
echo !
del .kill
goto main 
) 
   
) else (
echo No lock found.
)

:main
echo Starting firefox with custom profile and remoting disabled..
echo %username% > .lock
%1 %2 %3 %4 %5 %6 %7
echo Firefox has exited, deleting lock file..
del .lock
:END
