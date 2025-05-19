#!/bin/bash
# Test if you have sudo
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)." >&2
  exit 1
fi
sudo apt-get update
rm -f ./preseed-*.iso
if ls ./preseed-*.iso 1>/dev/null 2>&1; then
    echo "Faild to delete existion iso files in the Working dir."
    echo "Please close all programms that might have open the iso."
    echo "If all fails, a reboot might help."
    exit 1
fi
current_dir=$(pwd)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
    read -p "Do you want to download Debian                  (Yes or No):   " YesORNoD
    if [[ "$YesORNoD" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done

while true; do
    read -p "Do you want to setup username and passwords?    (Yes or No):   " YesORNoU
    if [[ "$YesORNoU" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done

while true; do
    read -p "Do you want to setup hostnames?                 (Yes or No):   " YesORNoH
    if [[ "$YesORNoH" =~ ^(Yes|No)$ ]]; then
        break
    else
        echo "Invalid input. Please enter 'Yes' or 'No'."
    fi
done
while true; do
    read -p "Do you want to use a custom background?         (Yes or No):   " YesORNoB
    if [[ "$YesORNoB" =~ ^(Yes|No)$ ]]; then
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
    clear
    echo "Download Debian Image"
    echo "Mirror: debian.ethz.ch  (Switzerland)"
    echo " "
    echo "Choose a number from 1 to 5:"
    echo "1) Debian 12.11.0  (newest, maby not working)"
    echo "2) Debian 11.07.0"
    echo "3) Debian 10.10.0"
    echo "4) Debian 09.09.0"
    echo "5) Debian 08.08.0"

    while true; do
        read -p "Enter:                                                     " DBVersionCHOICE
        if [[ "$DBVersionCHOICE" =~ ^[1-5]$ ]]; then
            break
        else
            echo "Invalid input. Please enter a number between 1 and 5."
        fi
    done
    while true; do
        read -p "Do you want to delete the iso at the end? (Yes or No):     " YesORNoIsoDel
        if [[ "$YesORNoIsoDel" =~ ^(Yes|No)$ ]]; then
            break
        else
            echo "Invalid input. Please enter 'Yes' or 'No'."
        fi
    done

    clear
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

    if [ "$DBVersionCHOICE" == "1" ]; then
        version="12.11.0"
        EXPECTED_HASH="30ca12a15cae6a1033e03ad59eb7f66a6d5a258dcf27acd115c2bd42d22640e8"
    elif [ "$DBVersionCHOICE" == "2" ]; then
        version="11.7.0"
        EXPECTED_HASH="eb3f96fd607e4b67e80f4fc15670feb7d9db5be50f4ca8d0bf07008cb025766b"
    elif [ "$DBVersionCHOICE" == "3" ]; then
        version="10.10.0"
        EXPECTED_HASH="c433254a7c5b5b9e6a05f9e1379a0bd6ab3323f89b56537b684b6d1bd1f8b6ad"
    elif [ "$DBVersionCHOICE" == "4" ]; then
        version="9.9.0"
        EXPECTED_HASH="d4a22c81c76a66558fb92e690ef70a5d67c685a08216701b15746586520f6e8e"
    elif [ "$DBVersionCHOICE" == "5" ]; then
        version="8.8.0"
        EXPECTED_HASH="2c07ff8cc766767610566297b8729740f923735e790c8e78b718fb93923b448e"
    fi
    
    BASE_URL="https://debian.ethz.ch/debian-cd/$version/amd64/iso-cd/debian-$version-amd64-netinst.iso"
    iso_path="debian-$version-amd64-netinst.iso"
    
    curl -O "$BASE_URL"

    clear
    echo "Verifying checksum..."
    ACTUAL_HASH=$(sha256sum "$iso_path" | awk '{print $1}')
    if [ "$EXPECTED_HASH" == "$ACTUAL_HASH" ]; then
        echo "Checksum verification PASSED."
    else
        clear
        echo "Checksum verification FAILED!"
        echo "ISO:      $iso_path"
        echo "Dwnload:  $BASE_URL"
        echo "Version:  $version"
        echo "Expected: $EXPECTED_HASH"
        echo "Actual:   $ACTUAL_HASH"
        exit 1
    fi

fi
isoOut="preseed-$(basename "$iso_path")"
clear
printf "The script won't ask for any more input."
sleep 0.5
printf "."
sleep 0.5
printf "."
sleep 0.5
printf "."
sleep 0.5
printf "."
sleep 0.5
printf "."
echo
clear



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
#sudo umount /mnt/iso 2>/dev/null
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

GRUB_CFG="/mnt/iso-new/boot/grub/grub.cfg"
if [ -f "$GRUB_CFG" ]; then
  cat <<EOF | sudo tee -a "$GRUB_CFG" > /dev/null
menuentry "Automatic Server Install" {
    set gfxpayload=keep
    linux /install.amd/vmlinuz auto=true priority=critical file=/cdrom/preseedserver1.cfg --- quiet
    initrd /install.amd/initrd.gz
}

menuentry "Automatic Desktop Install" {
    set gfxpayload=keep
    linux /install.amd/vmlinuz auto=true priority=critical file=/cdrom/preseeddesktop1.cfg --- quiet
    initrd /install.amd/initrd.gz
}

menuentry "Automatic Undefined Install" {
    set gfxpayload=keep
    linux /install.amd/vmlinuz auto=true priority=critical file=/cdrom/preseedundefined1.cfg --- quiet
    initrd /install.amd/initrd.gz
}
EOF
else
  echo "GRUB-Konfigurationsdatei (grub.cfg) nicht gefunden."
  echo "The Grub configuration cudd not be added to the ISO."
  echo "sleep 10 seconds"
  sleep 10
fi

if [ "$YesORNoD" == "No" ]; then
    sudo rm -rf /mnt/iso-new/isolinux/splash.png
    sudo cp "$script_dir/splash.png" /mnt/iso-new/isolinux
fi

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
printf "Script directory: \t%s\n" "$script_dir"
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
echo "Original Debian ISO Information:"
printf "Version:          \t%s\n" "$version"
printf "SHA256:           \t%s\n" "$EXPECTED_HASH"
printf "Download url:     \t%s\n" "$BASE_URL"
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



if [ "$YesORNoIsoDel" == "Yes" ]; then
    #echo "Deleting the original ISO..."
    sudo rm -rf "$iso_path"
fi