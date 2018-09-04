#!/bin/sh -x

efibootmgr -d /dev/sda -p 1 -c -L "Arch Linux" -l /vmlinuz-linux -u "quiet root=/dev/mapper/vglaptruc-lvroot rw resume=/dev/mapper/vglaptruc-lvroot resume_offset=329728 initrd=/initramfs-linux.img"
