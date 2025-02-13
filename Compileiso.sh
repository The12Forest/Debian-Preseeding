#!/bin/bash
echo
echo
echo

ls

echo
echo
echo

echo "Bitte gib das frische iso an:"
read isoIn
echo
echo "Bitte gibe die preseed Desktop datei an:"
read preseedDesktop
echo
echo "Bitte gibe die preseed Server datei an:"
read preseedServer

isoOut=preseed-${isoIn}

mkdir vanilla-iso new-iso
sudo mount -o loop $isoIn vanilla-iso
sudo cp -rT vanilla-iso/ new-iso/
sudo umount vanilla-iso

sudo cp ${isopreseedDesktopIn} new-iso
sudo cp ${preseedServer} new-iso

sudo cd new-iso
sudo mv ${preseedDesktop} preseeddesktop1.cfg
sudo mv ${preseedServer} preseedserver1.cfg

sudo cat >> new-iso/isolinux/adtxt.cfg <<EOF
label auto-wipe-server
        menu label ^Automatic Server install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseedserver1.cfg initrd=/install.amd/initrd.gz --- quiet

label auto-wipe-desktop
        menu label ^Automatic Desktop install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseeddesktop1.cfg initrd=/install.amd/initrd.gz --- quiet
EOF

sudo genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $isoOut ./new-iso

# Optional, falls das Image nur fuer VMs genutzt wird
sudo isohybrid $isoOut

sudo rm -rf new-iso vanilla-iso
