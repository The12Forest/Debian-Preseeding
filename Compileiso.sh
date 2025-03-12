#!/bin/bash
# Test if you have sudo
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)." >&2
  exit 1
fi
sudo apt-get update
rm -f ./preseed-*.iso
current_dir=$(pwd)
clear
while true; do
    read -p "Do you want to use the predefined preseed files (Yes or No):   " YesORNo
    if [[ "$YesORNo" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done

while true; do
    read -p "Do you want to download Debian 12.9 (Yes or No):               " YesORNoD
    if [[ "$YesORNoD" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done

while true; do
    read -p "Do you want to setup username and passwords? (Yes or No):      " YesORNoU
    if [[ "$YesORNoD" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done

while true; do
    read -p "Do you want to setup hostnames? (Yes or No):                   " YesORNoH
    if [[ "$YesORNoD" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done


# Setting up wariables
echo
if [ "$YesORNoD" == "No" ]; then
    clear
    echo Files in your current directory:
    echo
    ls
    echo
    echo "Please enter the name the Debian installer ISO:"
    read -p "Enter the path to the ISO file: " iso_path
    echo
fi

if [ "$YesORNo" == "Yes" ]; then
    isopreseedDesktopIn=preseedDesktop.cfg
    isopreseedServerIn=preseedServer.cfg
    isopreseedUndefinedIn=preseedUndefined.cfg
else
    clear
    echo Files in your current directory:
    ls
    echo
    echo "Please select the preseed file for Server that you want to use (Neds to be in the working Dir.):"
    read -p "Enter name of the file: " isopreseedServerIn
    clear
    echo Files in your current directory:
    ls
    echo
    echo "Please select the preseed file for Desktop that you want to use (Neds to be in the working Dir.):"
    read -p "Enter name of the file: " isopreseedDesktopIn
    clear
    echo Files in your current directory:
    ls
    echo
    echo "Please select the preseed file for Undefined that you want to use (Neds to be in the working Dir.):"
    read -p "Enter name of the file: " isopreseedUndefinedIn
fi

# Seting up user settings
if [ "$YesORNoU" == "Yes" ]; then
    clear
    sudo apt-get install whois -y
    clear
    read -p "Set the fullname for the main user:                                         " FULL_USER_NAME
    read -p "Set the username for the main user (All lovercase. Leve empty for default): " USER_NAME
    FIRST_NAME=$(echo "$FULL_USER_NAME" | awk '{print tolower($1)}')
    USER_NAME=${USER_NAME:-$FIRST_NAME}
    read -p "Set the password for the main user:                                         " USER_PASS
    read -p "Set the password for the root user:                                         " ROOT_PASSWORD
fi

# Seting up hostname
if [ "$YesORNoH" == "Yes" ]; then
    clear
    read -p "Set the hostname for the server installed with this ISO (Example 'server.local'. Leve empty for default.):              " hostnames
    read -p "Set the hostname for the desktops installed with this ISO (Example 'desktop.local'. Leve empty for default.):           " hostnamed
    read -p "Set the hostname for the other machines installed with this ISO (Example 'undefined.local'. Leve empty for default.):   " hostnameu
    
    hostnames=${hostnames:-"server.local"}
    hostnamed=${hostnamed:-"desktop.local"}
    hostnameu=${hostnameu:-"undefined.local"}
fi

# Install required packages
clear
printf "Instaling required packages"
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
echo

if [ "$YesORNoD" == "Yes" ]; then
    sudo apt-get install genisoimage isolinux syslinux-utils squashfs-tools curl -y
    clear
else 
    sudo apt-get install genisoimage isolinux syslinux-utils squashfs-tools -y
    clear
fi

# Download Debian Image
if [ "$YesORNoD" == "Yes" ]; then
    printf "Download Debian Image"
    sleep 0.3
    printf "."
    sleep 0.3
    printf "."
    sleep 0.3
    printf "."
    sleep 0.3
    printf "."
    sleep 0.3
    printf "."
    echo
    clear

    curl -O https://debian.ethz.ch/debian-cd/12.9.0/amd64/iso-cd/debian-12.9.0-amd64-netinst.iso
fi
isoOut="preseed-$(basename "$iso_path")"

# Creating Working Directory
clear
printf "Creating content for ISO Image"
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
echo
echo "Please wait..."
echo

sudo mkdir -p /mnt/iso
sudo mkdir -p /mnt/iso-new
sudo umount /mnt/iso 2>/dev/null
sudo mount -o loop,rw "$iso_path" /mnt/iso
sudo cp -rT /mnt/iso/ /mnt/iso-new/
sudo umount /mnt/iso

# Copy Preseed Files
cd "$current_dir"
sudo cp "$isopreseedDesktopIn" /mnt/iso-new
sudo cp "$isopreseedServerIn" /mnt/iso-new
sudo cp "$isopreseedUndefinedIn" /mnt/iso-new
cd /mnt/iso-new
sudo mv "$isopreseedDesktopIn" preseeddesktop1.cfg
sudo mv "$isopreseedServerIn" preseedserver1.cfg
sudo mv "$isopreseedUndefinedIn" preseedundefined1.cfg

# Editing Preseed Files
if [ "$YesORNoU" == "Yes" ]; then
    # Encrypting Passwords
    ENCRYPTED_USER_PASS=$(echo -n "$USER_PASS" | mkpasswd -m sha-512 -s)
    ENCRYPTED_ROOT_PASS=$(echo -n "$ROOT_PASSWORD" | mkpasswd -m sha-512 -s)

    # Server
    FILE="preseedserver1.cfg"
    HOSTNAME=$hostnames
    if [ "$YesORNoH" == "Yes" ]; then
        sed -i "s|^d-i netcfg/get_hostname string .*|d-i netcfg/get_hostname string $HOSTNAME|" "$FILE"
    fi
    sed -i "s|^d-i netcfg/get_hostname string .*|d-i netcfg/get_hostname string $HOSTNAME|" "$FILE"
    sed -i "s|^d-i passwd/username string .*|d-i passwd/username string $USER_NAME|" "$FILE"
    sed -i "s|^d-i passwd/user-fullname string .*|d-i passwd/user-fullname string $FULL_USER_NAME|" "$FILE"
    sed -i "/^#*d-i passwd\/root-password /d" "$FILE"
    sed -i "/^#*d-i passwd\/root-password-again /d" "$FILE"
    sed -i "/^#*d-i passwd\/root-password-crypted /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password-again /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password-crypted /d" "$FILE"
    echo "d-i passwd/root-password-crypted password $ENCRYPTED_ROOT_PASS" >> "$FILE"
    echo "d-i passwd/user-password-crypted password $ENCRYPTED_USER_PASS" >> "$FILE"

    # Desktop
    FILE="preseeddesktop1.cfg"
    HOSTNAME=$hostnamed
    if [ "$YesORNoH" == "Yes" ]; then
        sed -i "s|^d-i netcfg/get_hostname string .*|d-i netcfg/get_hostname string $HOSTNAME|" "$FILE"
    fi
    sed -i "s|^d-i passwd/username string .*|d-i passwd/username string $USER_NAME|" "$FILE"
    sed -i "s|^d-i passwd/user-fullname string .*|d-i passwd/user-fullname string $FULL_USER_NAME|" "$FILE"
    sed -i "/^#*d-i passwd\/root-password /d" "$FILE"
    sed -i "/^#*d-i passwd\/root-password-again /d" "$FILE"
    sed -i "/^#*d-i passwd\/root-password-crypted /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password-again /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password-crypted /d" "$FILE"
    echo "d-i passwd/root-password-crypted password $ENCRYPTED_ROOT_PASS" >> "$FILE"
    echo "d-i passwd/user-password-crypted password $ENCRYPTED_USER_PASS" >> "$FILE"

    # Undefined
    FILE="preseedundefined1.cfg"
    HOSTNAME=$hostnameu
    if [ "$YesORNoH" == "Yes" ]; then
        sed -i "s|^d-i netcfg/get_hostname string .*|d-i netcfg/get_hostname string $HOSTNAME|" "$FILE"
    fi
    sed -i "s|^d-i passwd/username string .*|d-i passwd/username string $USER_NAME|" "$FILE"
    sed -i "s|^d-i passwd/user-fullname string .*|d-i passwd/user-fullname string $FULL_USER_NAME|" "$FILE"
    sed -i "/^#*d-i passwd\/root-password /d" "$FILE"
    sed -i "/^#*d-i passwd\/root-password-again /d" "$FILE"
    sed -i "/^#*d-i passwd\/root-password-crypted /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password-again /d" "$FILE"
    sed -i "/^#*d-i passwd\/user-password-crypted /d" "$FILE"
    echo "d-i passwd/root-password-crypted password $ENCRYPTED_ROOT_PASS" >> "$FILE"
    echo "d-i passwd/user-password-crypted password $ENCRYPTED_USER_PASS" >> "$FILE"
fi

# Creating installer Menu entries
sudo tee -a /mnt/iso-new/isolinux/txt.cfg > /dev/null <<EOF
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

# Creating the new ISO
clear
printf "Creating ISO Image"
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
sleep 0.2
printf "."
echo

cd "$current_dir"
sudo genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$isoOut" /mnt/iso-new
sudo isohybrid "$isoOut"

# Cleanup Working Directory
cd "$current_dir"
echo "Cleaning up Working Directory..."
sudo rm -rf /mnt/iso
sudo rm -rf /mnt/iso-new
sudo rm -rf ./.temp

clear
printf "Preparing end Screen"
MD5="MD5:\t\t\t$(md5sum "$isoOut" | cut -d' ' -f1)\n"
printf "."
SHA1="SHA1:\t\t\t$(sha1sum "$isoOut" | cut -d' ' -f1)\n"
printf "."
SHA256="SHA256:\t\t\t$(sha256sum "$isoOut" | cut -d' ' -f1)\n"
printf "."
SHA512="SHA512:\t\t\t$(sha512sum "$isoOut" | cut -d' ' -f1)\n"
printf "."
sleep 0.2
printf "."
sleep 0.7

# Backtalk to the user (Endscreen)
clear
echo "Custom Debian ISO created:"
echo
printf "ISO:              \t%s\n" "$iso_path"
printf "Preseed Desktop:  \t%s\n" "$isopreseedDesktopIn"
printf "Preseed Server:   \t%s\n" "$isopreseedServerIn"
printf "Preseed Undefined:\t%s\n" "$isopreseedUndefinedIn"
printf "Path:             \t%s\n" "$current_dir"
printf "Full Path:        \t%s/%s\n" "$current_dir" "$isoOut"
printf "Default Size:     \t%s\n" "$(du -h "$iso_path" | cut -f1)"
printf "Preseed Size:     \t%s\n" "$(du -h "$isoOut" | cut -f1)"
printf "Permissions:      \t%s\n" "$(stat -c %a "$isoOut")"
printf "Owner:            \t%s\n" "$(stat -c %U "$isoOut")"
printf "Group:            \t%s\n" "$(stat -c %G "$isoOut")"
echo
echo Hashes of the ISO:
printf $MD5
printf $SHA1
printf $SHA256
printf $SHA512
echo
if [ "$YesORNoH" == "Yes" ]; then
echo "Hostname Server:              $hostnames"
echo "Hostname Desktop:             $hostnamed"
echo "Hostname Undefined:           $hostnameu"
echo
fi
echo "User Information:"
echo "  Root:"
echo "      Username:               root"
echo "      Password:               $ROOT_PASSWORD"
echo "      Encrypted:              $ENCRYPTED_ROOT_PASS"
echo "  User:"
echo "      Username:               $USER_NAME"
echo "      Password:               $USER_PASS"
echo "      Encrypted:              $ENCRYPTED_USER_PASS"
echo
echo
echo "Done! Thank you for using this script. Have a nice day!"
