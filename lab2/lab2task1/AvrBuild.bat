@ECHO OFF
"D:\apps\avr-studio\avr-studio-4\AvrAssembler2\avrasm2.exe" -S "D:\bmstu\sem6\mps\labs\lab2\lab2task1\labels.tmp" -fI -W+ie -C V2E -o "D:\bmstu\sem6\mps\labs\lab2\lab2task1\lab2task1.hex" -d "D:\bmstu\sem6\mps\labs\lab2\lab2task1\lab2task1.obj" -e "D:\bmstu\sem6\mps\labs\lab2\lab2task1\lab2task1.eep" -m "D:\bmstu\sem6\mps\labs\lab2\lab2task1\lab2task1.map" "D:\bmstu\sem6\mps\labs\lab2\lab2task1\lab2task1.asm"