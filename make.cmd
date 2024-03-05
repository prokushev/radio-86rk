@echo off

SET PATH=tools;%PATH%

md logs
md obj
md bin
md rk

echo ROM-disk Control Program 3.0
cd src\romctrl
call make
cd ..\..

echo BASIC
cd basic
call make
cd ..

echo TEST.COM
asw -lU src\test\test.asm -o obj\test.p> logs\test.lst
p2bin obj\test.p roms\romctrl\test.com

echo LOAD.ROM
asw -lU -i . src\load\load.asm -o obj\test.p > logs\load.lst
p2bin obj\load.p roms\romctrl\load.rom

echo SAVE.ROM
asw -lU -i . src\save\save.asm -o obj\save.p > logs\save.lst
p2bin obj\save.p roms\romctrl\save.rom

echo MONITOR 1.20 32KB
asw -lUa -i . -D BASE=07600H src\monitor\mon580-1.asm -o obj\mon580-1.p > logs\mon580-1-32.lst
p2bin obj\mon580-1.p roms\1.20-32\b2m\bios.rom
p2bin obj\mon580-1.p roms\1.20-32\b2m\radiorom.rom
p2bin obj\mon580-1.p roms\1.20-32\emu80\rk86.rom

echo MONITOR 1.20 16KB
asw -lU -i . -D BASE=03600H src\monitor\mon580-1.asm -o obj\mon580-1.p > logs\mon580-1-16.lst
p2bin obj\mon580-1.p roms\1.20-16\b2m\bios.rom
p2bin obj\mon580-1.p roms\1.20-16\b2m\radiorom.rom
p2bin obj\mon580-1.p roms\1.20-16\emu80\rk86.rom

echo Window Driver
asw -lUa -i . src\window\window.asm -o obj\window.p > logs\window.lst
p2bin obj\window.p

echo Window Driver 2.0
asw -lUa -i . src\window\window2.asm -o obj\window2.p> logs\window2.lst
p2bin obj\window2.p

echo ROM-DISK
asw -lUa -i . -i basic\bin\radio-86rk -i roms\romctrl -D STUB=1 src\romdisk\romdisk.asm -o obj\romdisk.p> logs\romdisk.lst
p2bin obj\romdisk.p roms\romdisk\b2m\romdisk.rom
p2bin obj\romdisk.p roms\romdisk\emu80\romdisk.bin


