# OS image layout:
#   os.img:
#     LBA 0      boot.bin
#     LBA 1-41   s2.bin          (41 sectors reserved)
#     LBA 42+    kernel.bin
#
# QEMU:
#   disk 0 / primary master: os.img     (bootloader + kernel)
#   disk 1 / secondary image: data.img  (simulated computer disk)
#copied from clanker
NASM      ?= nasm
CC      := x86_64-elf-gcc
LD      := x86_64-elf-ld
OBJCOPY := x86_64-elf-objcopy
QEMU      ?= qemu-system-x86_64

BUILD_DIR := build

OS_IMG       := os.img
DATA_IMG     := data.img
OS_DISK_SIZE := 2M
DATA_SIZE    := 20M

BOOT_BIN   := $(BUILD_DIR)/boot.bin
S2_BIN     := $(BUILD_DIR)/s2.bin
KENTRY_OBJ := $(BUILD_DIR)/kentry.o
KMAIN_OBJ  := $(BUILD_DIR)/main.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
KERNEL_BIN := $(BUILD_DIR)/kernel.bin

KERNEL_LBA := 42
STAGE2_RESERVED_SECTORS := 41

CFLAGS := -std=gnu11 -ffreestanding -O2 -Wall -Wextra \
          -fno-pie -fno-pic -fno-stack-protector -mno-red-zone \
          -nostdlib -nostdinc -Iinclude

LDFLAGS := -nostdlib -static -no-pie -z max-page-size=0x1000 -T linker.ld

.PHONY: all images run clean check

all: images

images: $(OS_IMG) $(DATA_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# 512-byte boot sector
$(BOOT_BIN): boot/boot.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

# Stage2 is raw flat binary loaded by bootloader from LBA 1.
$(S2_BIN): boot/s2.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@
	@bytes=$$(stat -c%s $@); \
	max=$$(( $(STAGE2_RESERVED_SECTORS) * 512 )); \
	if [ $$bytes -gt $$max ]; then \
		echo "ERROR: $@ is $$bytes bytes, but bootloader only reserves $$max bytes / $(STAGE2_RESERVED_SECTORS) sectors."; \
		exit 1; \
	fi

# 64-bit ASM kernel entry stub, linked with C.
$(KENTRY_OBJ): kernel/kentry.asm | $(BUILD_DIR)
	$(NASM) -f elf64 $< -o $@

$(KMAIN_OBJ): kernel/main.c include/kernel.h | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KENTRY_OBJ) $(KMAIN_OBJ) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(KENTRY_OBJ) $(KMAIN_OBJ)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@
	@bytes=$$(stat -c%s $@); \
	max=$$(( 1024 * 1024 )); \
	if [ $$bytes -gt $$max ]; then \
		echo "ERROR: kernel.bin is $$bytes bytes, bigger than 1 MiB load area 0x100000-0x1FFFFF."; \
		exit 1; \
	fi

# Bootable OS disk, 2 MiB raw image.
# boot.bin   -> LBA 0
# s2.bin     -> LBA 1
# kernel.bin -> LBA 42
$(OS_IMG): $(BOOT_BIN) $(S2_BIN) $(KERNEL_BIN)
	qemu-img create -f raw $@ $(OS_DISK_SIZE)
	dd if=$(BOOT_BIN)   of=$@ bs=512 seek=0 count=1 conv=notrunc
	dd if=$(S2_BIN)     of=$@ bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$@ bs=512 seek=$(KERNEL_LBA) conv=notrunc
	@echo "Created $(OS_IMG): raw $(OS_DISK_SIZE)"
	@echo "Kernel starts at LBA $(KERNEL_LBA). ATA Should be loaded onto EAX=$(KERNEL_LBA)."

# Separate simulated hard drive, 20 MiB raw image.
$(DATA_IMG):
	qemu-img create -f raw $@ $(DATA_SIZE)
	@echo "Created $(DATA_IMG): raw $(DATA_SIZE)"

run: images
	$(QEMU) \
		-smp 2 \
		-m 16M \
		-drive file=$(OS_IMG),format=raw,if=ide,index=0 \
		-drive file=$(DATA_IMG),format=raw,if=ide,index=1 \
		-serial stdio \
		-enable-kvm

check:
	@echo "OS disk:"
	@ls -lh $(OS_IMG) 2>/dev/null || true
	@echo "Data disk:"
	@ls -lh $(DATA_IMG) 2>/dev/null || true
	@echo "Build outputs:"
	@ls -lh $(BUILD_DIR) 2>/dev/null || true

clean:
	rm -rf $(BUILD_DIR) $(OS_IMG) $(DATA_IMG)
