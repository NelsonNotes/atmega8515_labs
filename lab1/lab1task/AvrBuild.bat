@ECHO OFF
"D:\apps\avr-studio\avr-studio-4\AvrAssembler2\avrasm2.exe" -S "D:\bmstu\sem6\mps\labs\lab1\lab1task\labels.tmp" -fI -W+ie -C V2E -o "D:\bmstu\sem6\mps\labs\lab1\lab1task\lab1.hex" -d "D:\bmstu\sem6\mps\labs\lab1\lab1task\lab1.obj" -e "D:\bmstu\sem6\mps\labs\lab1\lab1task\lab1.eep" -m "D:\bmstu\sem6\mps\labs\lab1\lab1task\lab1.map" "D:\bmstu\sem6\mps\labs\lab1\lab1task\lab1.asm"
