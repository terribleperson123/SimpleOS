all: disk.img

disk.img: boot.bin s2.bin
	qemu-img create -f raw disk.img 100M	
	dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=s2.bin of=disk.img bs=512 seek=1 conv=notrunc
	qemu-system-x86_64 -drive file=disk.img,format=raw,if=ide -m 16M -serial stdio -no-reboot
boot.bin:
	nasm -f bin boot/boot.asm -o boot.bin
s2.bin:
	nasm -f bin boot/s2.asm -o s2.bin
	
