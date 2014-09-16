app:
	cd mips-app && make board
	utils/bin2text.py mips-app/bootloader.bin rom.txt
boot:
	cd mips-boot && make board
	utils/bin2text.py mips-boot/bootloader.bin rom.txt
clean:
	-rm rom.txt
	cd mips-boot && make clean
	cd mips-app && make clean
    