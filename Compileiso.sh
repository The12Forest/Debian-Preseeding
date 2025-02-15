#!/bin/bash

rm -f ./preseed-*.iso

# Setting up wariables
echo
echo Files in your current directory:

ls

echo
echo
echo "Please enter the name the Debian installer ISO:"
read -p "Enter the path to the ISO file: " iso_path
echo
read -p "Do you want to use the predefined preseed files (Yes or No): " JesORNo
echo
if [ $JesORNo == "Yes" ]; then
    isopreseedDesktopIn=preseedDesktop.cfg
    isopreseedServerIn=preseedServer.cfg
    isopreseedUndefinedIn=preseedUndefined.cfg
else
    echo "Please select the preseed file for Server you want to use:"
    read -p "Enter the name of the Server Preseed file: " preseedServer
    echo
    echo "Please select the preseed file for Desktop you want to use:"
    read -p "Enter the name of the Desktop Preseed file: " preseedDesktop
    echo
    echo "Please select the preseed file for Undefined you want to use:"
    read -p "Enter the name of the Undefined Preseed file: " preseedDesktop
fi
isoOut="preseed-$(basename "$iso_path")"
current_dir=$(pwd)


# Creating Working Directory

sudo mkdir -p /mnt/iso
sudo mkdir -p /mnt/iso-new
sudo umount /mnt/iso 2>/dev/null
sudo mount -o loop,rw "$iso_path" /mnt/iso
sudo cp -rT /mnt/iso/ /mnt/iso-new/
sudo umount /mnt/iso


# Copy Preseed Files

sudo cp "$isopreseedDesktopIn" /mnt/iso-new
sudo cp "$preseedServer" /mnt/iso-new
sudo cp "$preseedUndefined" /mnt/iso-new

cd /mnt/iso-new
sudo mv "$preseedDesktop" preseeddesktop1.cfg
sudo mv "$preseedServer" preseedserver1.cfg
sudo mv "$preseedUndefined" preseedundefined1.cfg

# Creating installer Menu entries

sudo tee -a /mnt/iso-new/isolinux/adtxt.cfg > /dev/null <<EOF
label auto-wipe-server
        menu label ^Automatic Server install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseedserver1.cfg initrd=/install.amd/initrd.gz --- quiet

label auto-wipe-desktop
        menu label ^Automatic Desktop install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseeddesktop1.cfg initrd=/install.amd/initrd.gz --- quiet

label auto-wipe-undefined
        menu label ^Automatic Undefined install
        kernel /install.amd/vmlinuz
        append auto=true priority=critical vga=788 file=/cdrom/preseedundefined1.cfg initrd=/install.amd/initrd.gz --- quiet
EOF


cd "$current_dir"

# Creating the new ISO

sudo genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$isoOut" /mnt/iso-new
sudo isohybrid "$isoOut"

# Cleanup Working Directory
sudo rm -rf /mnt/iso
sudo rm -rf /mnt/iso-new

# Backtalk to the user
clear
echo "Custom Debian ISO created:"
echo
printf "ISO:              \t%s\n" "$iso_path"
printf "Preseed Desktop:  \t%s\n" "$isopreseedDesktopIn"
printf "Preseed Server:   \t%s\n" "$isopreseedServerIn"
printf "Preseed Undefined:\t%s\n" "$isopreseedUndefinedIn"
printf "Working Dir:      \t%s\n" "$current_dir"
printf "Path:             \t%s\n" "$current_dir"
printf "Name:             \t%s\n" "$isoOut"
printf "Full Path:        \t%s/%s\n" "$current_dir" "$isoOut"
printf "Size:             \t%s\n" "$(du -h "$isoOut" | cut -f1)"
printf "Permissions:      \t%s\n" "$(stat -c %a "$isoOut")"
printf "Owner:            \t%s\n" "$(stat -c %U "$isoOut")"
printf "Group:            \t%s\n" "$(stat -c %G "$isoOut")"
echo
echo Hashes:
printf "MD5:              \t%s\n" "$(md5sum "$isoOut" | cut -d' ' -f1)"
printf "SHA1:             \t%s\n" "$(sha1sum "$isoOut" | cut -d' ' -f1)"
printf "SHA256:           \t%s\n" "$(sha256sum "$isoOut" | cut -d' ' -f1)"
printf "SHA512:           \t%s\n" "$(sha512sum "$isoOut" | cut -d' ' -f1)"
printf "SHA3-256:         \t%s\n" "$(sha3sum -a 256 "$isoOut" | cut -d' ' -f1)"
printf "SHA3-512:         \t%s\n" "$(sha3sum -a 512 "$isoOut" | cut -d' ' -f1)"
printf "BLAKE2b-256:      \t%s\n" "$(b2sum -l 256 "$isoOut" | cut -d' ' -f1)"
printf "BLAKE2b-512:      \t%s\n" "$(b2sum -l 512 "$isoOut" | cut -d' ' -f1)"
printf "CRC32:            \t%s\n" "$(cksum "$isoOut" | cut -d' ' -f1)"
printf "CRC64:            \t%s\n" "$(cksum -o 1 "$isoOut" | cut -d' ' -f1)"
printf "Tiger:            \t%s\n" "$(tiger "$isoOut" | cut -d' ' -f1)"
printf "Whirlpool:        \t%s\n" "$(whirlpool "$isoOut" | cut -d' ' -f1)"
printf "RIPEMD160:        \t%s\n" "$(ripemd160 "$isoOut" | cut -d' ' -f1)"
printf "GOST:             \t%s\n" "$(gost "$isoOut" | cut -d' ' -f1)"
printf "Skein-256:        \t%s\n" "$(skein -l 256 "$isoOut" | cut -d' ' -f1)"
printf "Skein-512:        \t%s\n" "$(skein -l 512 "$isoOut" | cut -d' ' -f1)"
printf "Skein-1024:       \t%s\n" "$(skein -l 1024 "$isoOut" | cut -d' ' -f1)"

echo
echo "Done! Thank you for using this script. Have a nice day!"
