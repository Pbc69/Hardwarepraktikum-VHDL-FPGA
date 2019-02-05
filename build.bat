echo off
setlocal
goto _start_

:help
  echo   Kompiliert ein Modul einer Gruppe in die Work-Library.
  echo.
  echo   ^<parameter^>^:= ^<group^> ^<module^>
  echo   ^<group^>    ^:= Ordner der Gruppe
  echo   ^<module^>   ^:= pmemory
  echo              ^|  haregs
  echo              ^|  alu
  echo              ^|  datapath
  echo              ^|  control
  echo              ^|  indec
  echo              ^|  isralogic
  echo              ^|  isrrlogic
  echo              ^|  checkirq
  echo              ^|  irqlogic
  echo              ^|  pclogic
  echo              ^|  pcblock
  echo              ^|  cpu
  echo.
goto fin
:_start_



::Aufstieg in Ornderhierarchie, damit alle Befehle relativ zu diesem angegeben werden können
::(ist nötig für die Integration in PSPad)
:findRootDir
  if not exist _lib (
    pushd ..
    goto findRootDir
  )


::Umwandeln der Group in DosDir (ohne Leerzeichen) und Extraktion des tiefsten Ordners
::(ist nötig für die Integration in PSPad)
set group=%~s1\ 
:findGroup
  for /F "delims=\; tokens=1*" %%a in ("%group%") do (    
    if not "%%b"==" "  (
      set group=%%b
      goto findGroup
    )
    set group=%%a
  )
     
::Prüfen, ob für die angegebene Gruppe ein Ordner existiert 
if not exist %group%\ goto help  
     
::Liste der Module, die für das angegebene Modul verausgesetzt werden 
set reqList=                                                          
if .%2==.pmemory    goto build
if .%2==.haregs     goto build
if .%2==.alu        goto build
if .%2==.datapath  (set reqList=alu
                    goto build)
if .%2==.control    goto build
if .%2==.indec      goto build
if .%2==.isralogic  goto build
if .%2==.isrrlogic  goto build
if .%2==.checkirq   goto build                   
if .%2==.irqlogic  (set reqList=isralogic isrrlogic checkirq
                    goto build)
if .%2==.pclogic    goto build                   
if .%2==.pcblock   (set reqList=irqlogic pclogic
                    goto build)                   
if .%2==.cpu       (set reqList=pmemory haregs datapath control indec pcblock
                    goto build)
if .%2==.hugo44    (set reqList=cpu
                    goto build)                    

::Abbruch, falls keins dieser Module angegeben wurde
goto help


::Module in die work-Library compilieren
:build      
  for %%i in (%reqList%) do call build %1 %%i    
  echo == work ^<= %group%^.%2 ==
  ghdl -a --ieee=synopsys --workdir=_lib -P_lib %group%\design\%2.vhd   
goto fin



:fin
endlocal
