ifndef CROSS_COMPILE
CROSS_COMPILE = mips-linux-gnu-
endif
AS = $(CROSS_COMPILE)as
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

CFLAGS = -MD -fno-pic -static -fno-strict-aliasing -fno-builtin  -fno-stack-protector -mno-check-zero-division -fno-delayed-branch -Wall -Werror -O2  -EL -march=mips32 -mno-llsc -mno-imadd -mno-mad -I../include 
CFLAGS += -g
ASFLAGS = -MD -EL -mno-check-zero-division -mips32
LDFLAGS = -EL


CSRC = $(shell find . -name "*.c") $(shell find ../common -name "*.c")
SSRC = $(shell find . -name "*.S") $(shell find ../common -name "*.S")
OBJECTS = $(SSRC:.S=.o) $(CSRC:.c=.o) 
	
export	CROSS_COMPILE

# ********************
# Rules of Compilation
# ********************

all: $(OBJECTS)
	$(LD) $(LDFLAGS) -T ram-qemu.ld $(OBJECTS) -o bootloader
	$(OBJCOPY) -O binary bootloader bootloader.bin
	$(OBJDUMP) -D bootloader  > code.txt
board:$(OBJECTS)
	$(LD) $(LDFLAGS) -T ram-board.ld $(OBJECTS) -o bootloader
	$(OBJCOPY) -O binary bootloader bootloader.bin
	$(OBJDUMP) -D bootloader  > code.txt
run:
	qemu-system-mipsel -kernel bootloader -serial stdio
debug:
	qemu-system-mipsel -kernel bootloader -serial stdio  -S -gdb tcp::1234
clean:
	-rm bootloader* $(OBJECTS) $(OBJECTS:.o=.d) code.txt

	
