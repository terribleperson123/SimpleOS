NASM ?= nasm
CC := x86_64-elf-gcc
LD := x86_64-elf-ld
OBJCOPY := x86_64-elf-objcopy
QEMU ?= qemu-system-x86_64

BUILD_DIR := build

OS_IMG := os.img
DATA_IMG := data.img
OS_DISK_SIZE := 2M
DATA_SIZE := 20M

BOOT_BIN := $(BUILD_DIR)/boot.bin
S2_BIN := $(BUILD_DIR)/s2.bin
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
KERNEL_BIN := $(BUILD_DIR)/kernel.bin

KERNEL_LBA := 42
STAGE2_RESERVED_SECTORS := 41

LINKER := linker.ld

KERNEL_C_SRCS := $(wildcard kernel/*.c)
KERNEL_ASM_SRCS := $(wildcard kernel/*.asm)

KERNEL_C_OBJS := $(patsubst kernel/%.c,$(BUILD_DIR)/kernel/%.o,$(KERNEL_C_SRCS))
KERNEL_ASM_OBJS := $(patsubst kernel/%.asm,$(BUILD_DIR)/kernel/%.o,$(KERNEL_ASM_SRCS))
KERNEL_OBJS := $(KERNEL_ASM_OBJS) $(KERNEL_C_OBJS)

CFLAGS := -std=gnu11 -ffreestanding -O2 -Wall -Wextra \
          -fno-pie -fno-pic -fno-stack-protector -mno-red-zone \
          -nostdinc -Iinclude

LDFLAGS := -nostdlib -static -no-pie -z max-page-size=0x1000 -T $(LINKER)

.PHONY: all images run clean check

all: images

images: $(OS_IMG) $(DATA_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/kernel:
	mkdir -p $(BUILD_DIR)/kernel

$(BOOT_BIN): boot/boot.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

$(S2_BIN): boot/s2.asm | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@
	@bytes=$$(stat -c%s $@); \
	max=$$(( $(STAGE2_RESERVED_SECTORS) * 512 )); \
	if [ $$bytes -gt $$max ]; then \
		echo "ERROR: $@ is $$bytes bytes, but bootloader only reserves $$max bytes / $(STAGE2_RESERVED_SECTORS) sectors."; \
		exit 1; \
	fi

$(BUILD_DIR)/kernel/%.o: kernel/%.asm | $(BUILD_DIR)/kernel
	$(NASM) -f elf64 $< -o $@

$(BUILD_DIR)/kernel/%.o: kernel/%.c | $(BUILD_DIR)/kernel
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KERNEL_OBJS) $(LINKER)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJS)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@
	@bytes=$$(stat -c%s $@); \
	max=$$(( 1024 * 1024 )); \
	if [ $$bytes -gt $$max ]; then \
		echo "ERROR: kernel.bin is $$bytes bytes, bigger than 1 MiB load area 0x100000-0x1FFFFF."; \
		exit 1; \
	fi

$(OS_IMG): $(BOOT_BIN) $(S2_BIN) $(KERNEL_BIN)
	qemu-img create -f raw $@ $(OS_DISK_SIZE)
	dd if=$(BOOT_BIN) of=$@ bs=512 seek=0 count=1 conv=notrunc
	dd if=$(S2_BIN) of=$@ bs=512 seek=1 conv=notrunc
	dd if=$(KERNEL_BIN) of=$@ bs=512 seek=$(KERNEL_LBA) conv=notrunc
	@echo "Created $(OS_IMG): raw $(OS_DISK_SIZE)"
	@echo "Kernel starts at LBA $(KERNEL_LBA). ATA should load kernel from LBA $(KERNEL_LBA)."

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
	@echo "Kernel objects:"
	@ls -lh $(BUILD_DIR)/kernel 2>/dev/null || true

clean:
	rm -rf $(BUILD_DIR) $(OS_IMG) $(DATA_IMG)
