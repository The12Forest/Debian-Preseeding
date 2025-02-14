#!/bin/bash
echo
echo
echo

ls

echo
echo
echo


echo "Please enter the name the Debian installer ISO:"
read -p "Enter the path to the ISO file: " iso_path
echo
echo "Please select the preseed file for Server you want to use:"
read -p "Enter the name of the Server Preseed file: " preseedServer
echo
echo "Please select the preseed file for Desktop you want to use:"
read -p "Enter the name of the Desktop Preseed file: " preseedDesktop
clear

isoOut=preseed-${isoIn}

sudo mount -o loop,rw $isoIn /mnt/iso
mkdir /mnt/iso /mnt/iso-new
sudo cp -rT /mnt/iso/ /mnt/iso-new/
sudo umount /mnt/iso


sudo cp ${isopreseedDesktopIn} /mnt/iso-new
sudo cp ${preseedServer} /mnt/iso-new

# sudo cd /mnt/iso-new
sudo mv ${preseedDesktop} preseeddesktop1.cfg
sudo mv ${preseedServer} preseedserver1.cfg

sudo cat >> /mnt/iso-new/isolinux/adtxt.cfg <<EOF
label auto-wipe-server
        menu label ^Automatic Server install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseedserver1.cfg initrd=/install.amd/initrd.gz --- quiet

label auto-wipe-desktop
        menu label ^Automatic Desktop install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseeddesktop1.cfg initrd=/install.amd/initrd.gz --- quiet
EOF


# cd

sudo genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $isoOut /mnt/iso-new

sudo isohybrid $isoOut

sudo rm -rf /mnt/iso-new
