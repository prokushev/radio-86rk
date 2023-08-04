@echo off

SET PATH=tools;%PATH%

echo MONITOR 1.20 32KB
asw -lUa -i . -i roms\romctrl -D BASE=07600H -D STUB=1 mon580-2-rom.asm > mon580-2-32-rom-1.lst
asw -lUa -i . -D BASE=07600H src\monitor\mon580-1.asm > mon580-1-32.lst
asw -lUa -i . -i roms\romctrl -D BASE=07600H -D STUB=0 mon580-2-rom.asm > mon580-2-32-rom-2.lst

exit

:asw -lU -i . -D BASE=07600H src\monitor\mon580-1.asm > mon580-1-32.lst

p2bin src\monitor\mon580-1.p roms\1.20-32\b2m\bios.rom
p2bin src\monitor\mon580-1.p roms\1.20-32\b2m\radiorom.rom
p2bin src\monitor\mon580-1.p roms\1.20-32\emu80\rk86.rom

echo MONITOR 1.20 16KB
asw -lU -i . -D BASE=03600H src\monitor\mon580-1.asm > mon580-1-16.lst
p2bin src\monitor\mon580-1.p roms\1.20-16\b2m\bios.rom
p2bin src\monitor\mon580-1.p roms\1.20-16\b2m\radiorom.rom
p2bin src\monitor\mon580-1.p roms\1.20-16\emu80\rk86.rom

echo DUMP.COM
asw -lU src\dump\dump.asm > dump.lst
p2bin src\dump\dump.p dump.com

echo TEST.COM
asw -lU src\test\test.asm > test.lst
p2bin src\test\test.p test.com

echo LOAD.ROM
asw -lU -i . src\load\load.asm > load.lst
p2bin src\load\load.p load.rom

echo SAVE.ROM
asw -lU -i . src\save\save.asm > save.lst
p2bin src\save\save.p save.rom

echo ROM-disk Control Program 3.0
asw -lU -i . -D BASE=07600H src\romctrl\romctrl.asm > romctrl-3-32.lst
p2bin src\romctrl\romctrl.p roms\romctrl\romctrl32k.rom

asw -lU -i . -D BASE=04600H src\romctrl\romctrl.asm > romctrl-3-16.lst
p2bin src\romctrl\romctrl.p roms\romctrl\romctrl16k.rom

echo MONITOR 2.00 32KB
asw -lUa -i roms\romctrl -D BASE=07600H -D STUB=1 mon580-2-rom.asm > mon580-2-32-rom-1.lst
p2bin mon580-2-rom.p roms\2.00-32\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-32\emu80\romdisk.bin

asw -lUa -D BASE=07600H mon580-2.asm > mon580-2-32.lst
p2bin mon580-2.p roms\2.00-32\b2m\radiorom.rom
p2bin mon580-2.p roms\2.00-32\emu80\rk86.rom

asw -lUa -i roms\romctrl -D BASE=07600H -D STUB=0 mon580-2-rom.asm > mon580-2-32-rom-2.lst
p2bin mon580-2-rom.p roms\2.00-32\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\1.20-32\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-32\emu80\romdisk.bin
p2bin mon580-2-rom.p roms\1.20-32\emu80\romdisk.bin

echo MONITOR 2.00 16KB
asw -lUa -i roms\romctrl -D BASE=03600H -D STUB=1 mon580-2-rom.asm > mon580-2-16-rom-1.lst
p2bin mon580-2-rom.p roms\2.00-16\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-16\emu80\romdisk.bin

asw -lUa -D BASE=03600H mon580-2.asm > mon580-2-16.lst
p2bin mon580-2.p roms\2.00-16\b2m\radiorom.rom
p2bin mon580-2.p roms\2.00-16\emu80\rk86.rom

asw -lUa -i roms\romctrl -D BASE=03600H -D STUB=0 mon580-2-rom.asm > mon580-2-16-rom-2.lst
p2bin mon580-2-rom.p roms\2.00-16\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\1.20-16\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-16\emu80\romdisk.bin
p2bin mon580-2-rom.p roms\1.20-16\emu80\romdisk.bin

