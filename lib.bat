echo off
setlocal
goto _start_

:help
  echo   Erstellt oder Loescht eine Library oder zeigt deren Inhalt an.
  echo.
  echo   ^<parameter^>^:= ^<lib^> ^[build ^| clean^]
  echo   ^<lib^>      ^:= all ^| work ^| xbus_sim ^| xbus_common ^| xbus_synth ^| unisim
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


::Liste der Module, die in die angegebene Library aufgenommen werden sollen
if .%1==.work       (set list=hadescomponents hades_addsub hades_compare hades_mul hades_shift hades_ram_dp irqreceiver
                     goto lib)
if .%1==.xbus_sim   (set list=xdmemory_sim xbus_sim
                     goto lib)                     
if .%1==.xbus_common   (set list=xtoolbox xtimerxt
                     goto lib)       
if .%1==.xbus_synth (set list=xddr2_mig xddr2_package xddr2_arbiter xddr2_ctrl xddr2_cache xdmemory_dcache xvga_rcache xvga_wcache xvga_out xvga xconsole xlcd xps2 xuart xbus_syn 
                     goto lib)                     
if .%1==.unisim     (set list=unisim_VCOMP unisim_VPKG
                     goto lib)
if .%1==.all        (set list=unisim xbus_common xbus_sim xbus_synth work
                     goto all)                     
          
                     
::Abbruch, falls keines dieser Module angegeben wurde
goto help
                     
                     
::Aktion für alle Librarys ausführen
:all
  for %%i in (%list%) do call lib %%i %2
goto fin                     

::Prüfen, ob angegebene Library angezeigt, gebaut oder gelöscht werden soll 
:lib
  if .%2==.      goto show
  if .%2==.build goto build
  if .%2==.clean goto clean


::Abbruch, falls keine dieser Möglichkeiten angegeben wurde
goto help

  
::Inhalt der Library anzeigen  
:show
  echo == %1 ==
  ghdl -d --workdir=_lib --work=%1
  echo.
goto fin
  
::Library löschen 
:clean
  echo == clean %1 ==
  if exist _lib\%1*.cf del _lib\%1*.cf 
goto fin
  
::Library bauen
:build
  for %%i in (%list%) do (
    echo == %1 ^<= %%i ==
    if "%%i"=="xddr2_mig" (
        ghdl -a --ieee=synopsys -fexplicit --workdir=_lib -P_lib --work=xbus_synth _lib/xbus_synth/xddr2_mig.vhd
      ) ELSE (    
        ghdl -a --workdir=_lib -P_lib --work=%1 _lib\%1\%%i.vhd
      )
  )
goto fin


:fin
endlocal
