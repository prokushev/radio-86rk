asw -lU -D BASE=07600H mon580-306-vt52.asm > mon580-1-32.lst
p2bin mon580-306-vt52.p bios.rom
asw -lU -D BASE=03600H mon580-306-vt52.asm > mon580-1-16.lst
p2bin mon580-306-vt52.p bios16k.rom
asw -lUa -D STUB=1 mon580-2-rom.asm > mon580-2-rom-1.lst
p2bin mon580-2-rom.p romdisk.rom
asw -lUa -D BASE=07600H mon580-2.asm > mon580-2-32.lst
p2bin mon580-2.p radiorom.rom
asw -lUa -D BASE=03600H mon580-2.asm > mon580-2-16.lst
p2bin mon580-2.p radiorom16k.rom
asw -lUa -D STUB=0 mon580-2-rom.asm > mon580-2-rom-2.lst
p2bin mon580-2-rom.p romdisk.rom
