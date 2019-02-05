# Hardwarepraktikum VHDL & FPGA
CPU Entwurf in VHDL und Programmierung eines Artix-7 FPGA Boards. Hardwarepraktikum Uni Würzburg WS18


## Benötigte Programme
Zum Schreiben von Code kann der Editor Visual Studio Code oder PSPad benutzt werden.
Für VS Code gibt es Plugins die VHDL Syntax highlighten und Fehler erkennen. Es liegen BuildTasks im Projekt vor-

#### Für VHDL Programmierung
GHDL v0.35: https://github.com/ghdl/ghdl/releases
GtkWave: https://sourceforge.net/projects/gtkwave/files/


# Anleitungen
**Anleitung.pdf**
 - Weitere Anleitungen wie man was zum Laufen bekommt
 - Assembler Befehle

**MDLab.pdf**
 - Logic einzelner Komponenten der CPU
 - Artix-7 FPGA Board Elemente


## Artix-7 FPGA Board Programmierung
### Vivado Bit-File generieren


 1. BOARD per USB anschließen und extra JUMPER in linken oberen Port stecken
 2. Alle **.vhdl** Dateien in den **hadesXI_13/rtl** Ordner kopieren
2. **HaDes.xpr** in Vivado öffnen und alles builden
3.1 Generate Bitstream (erstellt mcu.bit)
3.2 Hardware Manager - open board - auto connect > Program Device und **mcu.bit** auswählen
4. Das Board ist nun programmiert


### Assembler Programm (.hix) aufs Board laden
1. _assembler/bin/Hterm.exe starten
2. Port auswählen & Connect
3. Im Input Control die **.hix** Datei auswählen und an das Board senden


### Programme

 - Zeichenprogramm: hadesXI_13/assembler/main.hix
 - Demoprogramm: _assembler/tests/basys3_demo.hix


# Tips
## VHDL
Zugriff auf Signal aus mehreren Prozessen ist nicht möglich. Es entsteht ein undefinied Konflikt (U). Um das Problem zu lösen, muss in einem Prozess ein neues Signal gesetzt werden, was dann von dem nächsten Prozess verwendet wird