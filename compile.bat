@echo off
setlocal
goto _start_

:help
  echo   Uebersetzt und bindet das Assembler-Programm einer Gruppe.
  echo.
  echo   ^<parameter^>^:= ^<group^>
  echo   ^<group^>    ^:= Ordner der Gruppe
  echo.
goto fin
:_start_



::Aufstieg in Ornderhierarchie, damit alle Befehle relativ zu diesem angegeben werden kíµ¶í½¥n
::(ist ní¶Ží¸§ fr die Integration in PSPad)
:findRootDir
  if not exist _lib (
    pushd ..
    goto findRootDir
  )


::Umwandeln der Group in DosDir (ohne Leerzeichen) und Extraktion des tiefsten Ordners
::(ist ní¶Ží¸§ fr die Integration in PSPad)
set group=%~s1\ 
:findGroup
  for /F "delims=\; tokens=1*" %%a in ("%group%") do (    
    if not "%%b"==" "  (
      set group=%%b
      goto findGroup
    )
    set group=%%a
  )
    
::Pfade zu Programm-Dateien
set p=%group%\assembler

::Prfen, ob Pfad existiert 
if not exist %p% goto help  

::Hauptdatei suchen
for /r %p% %%f in (*.has) do (
  for /f "tokens=1" %%a in ('find "__init" "%%f"') do (    
    if .%%a==.@code (
      set file=%%f
      goto hoasm
    )    
  )  
)
goto fin

::Aufruf von Assembler und Linker
:hoasm
  _assembler\bin\hoasm -I _assembler\inc "%file%"
  _assembler\bin\hlink -L _assembler\inc -o "%file:.has=.hix%" "%file:.has=.ho%"

  
:fin
endlocal
