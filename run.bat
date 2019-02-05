echo off
setlocal
goto _start_

:help
  echo   fuehrt eine TestBench eines Moduls (oder alle TestBenches) aus,
  echo   erzeugt die Waveform und zeigt sie ggf. an
  echo.
  echo   ^<parameter^>^:= ^<group^> ^{all ^| ^{^<module^> ^[show^]^}^}
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
  echo              ^|  cpu ^<num^>
  echo   ^<num^>      ^:= 1 ^| 2 ^| 3 ^| 4 ^| 5
  echo.
goto fin

:laufzeit
  echo Es konnte keine Laufzeitangabe in der Testbench gefunden werden.
  echo Bitte eine Kommentarzeile mit "-- Laufzeit: <wert>ns" in die TestBench einfügen.
  echo.
goto fin

:_start_



::Aufstieg in Ornderhierarchie, damit alle Befehle relativ zu diesem angegeben werden können
::(ist nötig für die Integation in PSPad)
:findRootDir
  if not exist _lib (
    pushd ..
    goto findRootDir
  )


::Umwandeln der group in DosDir und extraktion des tiefsten Ordners
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


::Prüfen, ob alle TestBenches ausgeführt werden sollen
if .%2==.all        goto all


::Name der Testbench des Moduls
::(muss in %group%\testbench\%2_tb geändert werden, wenn die Tests von den Praktikumsteilnehmern zu 
:: erstellen sind)
set source=_testbench\%2_tb
::set source=%group%\testbench\%2_tb

::Show-Flag: wenn s=show => waveform mit gtkwave anzeigen
set s=%3

::Nummer des CPU-Tests, der ausgeführt werden soll
set n=


::Prüfen, welches Modul getestet werden soll
if .%2==.pmemory    goto stoptime
if .%2==.haregs     goto stoptime
if .%2==.alu        goto stoptime
if .%2==.datapath   goto stoptime
if .%2==.control    goto stoptime
if .%2==.indec      goto stoptime
if .%2==.isralogic  goto stoptime
if .%2==.isrrlogic  goto stoptime
if .%2==.checkirq   goto stoptime                   
if .%2==.irqlogic   goto stoptime
if .%2==.pclogic    goto stoptime                   
if .%2==.pcblock    goto stoptime                   
if .%2==.cpu        goto cpu
                                     

::Abbruch, falls keines dieser Module angegeben wurde
goto help


::Abfrage der Nummer des CPU-Tests, der gestartet werden soll
:cpu  
  set s=%4  
  if .%3==.show set s=show
  if .%3==.2    set n=2
  if .%3==.3    set n=3
  if .%3==.4    set n=4
  if .%3==.5    set n=5
  if .%n%==.    set n=1
                   
::Nummer des Tests in eine Datei Schreiben, die in cpu_tb wieder ausgelesen wird                 
  echo %n% >> _testbench\cpu_tb.num
  
::Ermittlung der Laufzeit des CPU-Tests aus dem Kommentar in der .mif Datei 
:: % Laufzeit @25MHz: ###ns
  for /F "tokens=1-4" %%a in ('find "Laufzeit @50MHz:" %source%%n%.mif') do (    
    if .%%b==.Laufzeit set stoptime=%%d
  )
goto run


::Ermittlung der Laufzeit der Tests aus dem Kommentar in der Testbench 
:: -- Laufzeit: ###ns
:stoptime
  for /F "tokens=1-3" %%a in ('find "-- Laufzeit:" %source%.vhd') do (
    if .%%b==.Laufzeit: set stoptime=%%c
  )
  if "%stoptime%"=="" goto laufzeit
goto run



::TestBench compilieren und ausführen und ggf. Waveform anzeigen
:run
  
  echo == work ^<= %source% ==
  ghdl -a --workdir=_lib -P_lib %source%.vhd

::Waveforms der CPU-Tests werden explizit im Gruppenordner abgelegt
  set wave=%source%
  if .%2==.cpu (
    set wave=_testbench\cpu_tb%n%
    set source=%source%%n%
  )
    
  echo == run %2_tb for %stoptime% ==    
  ghdl -r --workdir=_lib -P_lib %2_tb --stop-time=%stoptime% --wave=%wave%.ghw --stack-max-size=1000000kb
  
::ggf. CPU-Test-Hilfsdatei wieder löschen  
  if .%2==.cpu del _testbench\cpu_tb.num 
    
  if .%s%==.show (
    echo == show waveform ==
    gtkwave %wave%.ghw %wave%.sav
  )
goto fin  
  
  
::Alle Module testen
:all
  for %%i in (pmemory haregs alu datapath control indec isralogic isrrlogic checkirq irqlogic pclogic pcblock cpu) do (
    call run %1 %%i
  )
goto fin
  
:fin
endlocal
