@ECHO OFF
IF NOT "%~f0" == "~f0" GOTO :WinNT
@"C:\Ruby23\bin\ruby.exe" "C:/Ruby23/bin/rbrcc" %1 %2 %3 %4 %5 %6 %7 %8 %9
GOTO :EOF
:WinNT
@"C:\Ruby23\bin\ruby.exe" "%~dpn0" %*
