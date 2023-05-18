rem MONITOR 1.20 32KB
asw -lU -D BASE=07600H mon580-1.asm > mon580-1-32.lst
p2bin mon580-1.p bios.rom

rem MONITOR 1.20 16KB
asw -lU -D BASE=03600H mon580-1.asm > mon580-1-16.lst
p2bin mon580-1.p bios16k.rom

rem MONITOR 2.00 32KB
asw -lUa -D BASE=07600H -D STUB=1 mon580-2-rom.asm > mon580-2-32-rom-1.lst
p2bin mon580-2-rom.p romdisk.rom
asw -lUa -D BASE=07600H mon580-2.asm > mon580-2-32.lst
p2bin mon580-2.p radiorom.rom
asw -lUa -D -D BASE=07600H STUB=0 mon580-2-rom.asm > mon580-2-32-rom-2.lst
p2bin mon580-2-rom.p romdisk.rom

rem MONITOR 2.00 16KB
asw -lUa -D BASE=03600H -D STUB=1 mon580-2-rom.asm > mon580-2-16-rom-1.lst
p2bin mon580-2-rom.p romdisk16k.rom
asw -lUa -D BASE=03600H mon580-2.asm > mon580-2-16.lst
p2bin mon580-2.p radiorom16k.rom
asw -lUa -D -D BASE=03600H STUB=0 mon580-2-rom.asm > mon580-2-16-rom-2.lst
p2bin mon580-2-rom.p romdisk16k.rom
