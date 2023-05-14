asw -lU mon580-306-vt52.asm > mon580-306-vt52.lst
p2bin mon580-306-vt52.p bios.rom
asw -lUa mon580-2-rom.asm > mon580-2-rom.lst
p2bin mon580-2-rom.p romdisk.rom
asw -lU mon580-2.asm > mon580-2.lst
p2bin mon580-2.p radiorom.rom
