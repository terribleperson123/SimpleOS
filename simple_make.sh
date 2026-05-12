qemu-img create -f raw disk.img 100M
nasm -f bin boot/boot.asm -o boot.bin
dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc

qemu-system-x86_64 -drive file=disk.img,format=raw,if=ide -m 16M -serial stdio -no-reboot

rm -rf boot.bin disk.img 
