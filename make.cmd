asw -lU mon580-306-vt52.asm > mon580-306-vt52.lst
p2bin mon580-306-vt52.p bios.rom
asw -lUa -D STUB=1 mon580-2-rom.asm > mon580-2-rom-1.lst
p2bin mon580-2-rom.p romdisk.rom
asw -lUa mon580-2.asm > mon580-2.lst
p2bin mon580-2.p radiorom.rom
asw -lUa -D STUB=0 mon580-2-rom.asm > mon580-2-rom-2.lst
p2bin mon580-2-rom.p romdisk.rom
