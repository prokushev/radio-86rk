@echo off

SET PATH=tools;%PATH%

echo MONITOR 1.20 32KB
asw -lU -D BASE=07600H mon580-1.asm > mon580-1-32.lst
p2bin mon580-1.p roms\1.20-32\b2m\bios.rom
p2bin mon580-1.p roms\1.20-32\emu80\rk86.rom

echo MONITOR 1.20 16KB
asw -lU -D BASE=03600H mon580-1.asm > mon580-1-16.lst
p2bin mon580-1.p roms\1.20-16\b2m\bios.rom
p2bin mon580-1.p roms\1.20-16\emu80\rk86.rom

echo MONITOR 2.00 32KB
asw -lUa -D BASE=07600H -D STUB=1 mon580-2-rom.asm > mon580-2-32-rom-1.lst
p2bin mon580-2-rom.p roms\2.00-32\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-32\emu80\romdisk.bin
asw -lUa -D BASE=07600H mon580-2.asm > mon580-2-32.lst
p2bin mon580-2.p roms\2.00-32\b2m\radiorom.rom
p2bin mon580-2.p roms\2.00-32\emu80\rk86.rom
asw -lUa -D BASE=07600H -D STUB=0 mon580-2-rom.asm > mon580-2-32-rom-2.lst
p2bin mon580-2-rom.p roms\2.00-32\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-32\emu80\romdisk.bin

echo MONITOR 2.00 16KB
asw -lUa -D BASE=03600H -D STUB=1 mon580-2-rom.asm > mon580-2-16-rom-1.lst
p2bin mon580-2-rom.p roms\2.00-16\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-16\emu80\romdisk.bin
asw -lUa -D BASE=03600H mon580-2.asm > mon580-2-16.lst
p2bin mon580-2.p roms\2.00-16\b2m\radiorom.rom
p2bin mon580-2.p roms\2.00-16\emu80\rk86.rom
asw -lUa -D BASE=03600H -D STUB=0 mon580-2-rom.asm > mon580-2-16-rom-2.lst
p2bin mon580-2-rom.p roms\2.00-16\b2m\romdisk.rom
p2bin mon580-2-rom.p roms\2.00-16\emu80\romdisk.bin

