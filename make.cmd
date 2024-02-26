@echo off

SET PATH=tools;%PATH%

md logs

echo ROM-disk Control Program 3.0
cd src\romctrl
call make
cd ..\..

echo BASIC
cd basic
call make
cd ..

echo TEST.COM
asw -lU src\test\test.asm > logs\test.lst
p2bin src\test\test.p roms\romctrl\test.com

echo LOAD.ROM
asw -lU -i . src\load\load.asm > logs\load.lst
p2bin src\load\load.p roms\romctrl\load.rom

echo SAVE.ROM
asw -lU -i . src\save\save.asm > logs\save.lst
p2bin src\save\save.p roms\romctrl\save.rom

echo MONITOR 1.20 32KB
asw -lUa -i . -D BASE=07600H src\monitor\mon580-1.asm > logs\mon580-1-32.lst
p2bin src\monitor\mon580-1.p roms\1.20-32\b2m\bios.rom
p2bin src\monitor\mon580-1.p roms\1.20-32\b2m\radiorom.rom
p2bin src\monitor\mon580-1.p roms\1.20-32\emu80\rk86.rom

echo MONITOR 1.20 16KB
asw -lU -i . -D BASE=03600H src\monitor\mon580-1.asm > logs\mon580-1-16.lst
p2bin src\monitor\mon580-1.p roms\1.20-16\b2m\bios.rom
p2bin src\monitor\mon580-1.p roms\1.20-16\b2m\radiorom.rom
p2bin src\monitor\mon580-1.p roms\1.20-16\emu80\rk86.rom

echo ROM-DISK
asw -lUa -i . -i basic\bin\radio-86rk -i roms\romctrl -D STUB=1 src\romdisk\romdisk.asm > logs\romdisk.lst
p2bin src\romdisk\romdisk.p roms\romdisk\b2m\romdisk.rom
p2bin src\romdisk\romdisk.p roms\romdisk\emu80\romdisk.bin


