# Debian Preseeding

This repository contains preseed configuration files (`preseedServer.cfg`, `preseedDesktop.cfg`, `preseedUndefined.cfg`) for automating the installation of Debian Linux.

## What is Preseeding?

Preseeding is a method for automating the Debian installation process. By providing answers to the installation prompts in advance, you can perform unattended installations, which is particularly useful for deploying multiple systems with the same configuration.

## Usage

To use the `preseedServer.cfg`/`preseedDesktop.cfg`/`preseedUndefined.cfg` file for a Debian installation, follow these steps:

1. **Download the Debian Installer ISO**: Obtain the Debian installer ISO from the [official Debian website](https://www.debian.org/distrib/) or use the built in download function for Debian 12.9.

2. **Update the Password**: Modify the `preseedServer.cfg`/`preseedDesktop.cfg`/`preseedUndefined.cfg` files to update the password as needed. It is recommended to use a hashed password, but you can also define it in plain text.

3. **Modify the ISO**: Add the `preseed.cfg` file to the ISO using my script `Compileiso.sh`.

4. **Execute the Script**: Make the sript executable and then RUN it. Using:
``
sudo chmod +x Compileiso.sh
sudo ./Compileiso.sh
``

5. **Boot from the ISO**: Boot the target machine from the modified ISO.

6. **Specify the Preseed File**: When prompted, go to the Extra options tab and use one of the new Crated entries.

## Customization

You can customize the `preseed.cfg` file to suit your specific needs. The file contains various settings that control different aspects of the installation process, such as partitioning, package selection, and network configuration.

Refer to the [Debian Installation Guide](https://www.debian.org/releases/stable/amd64/apb.html.en) for detailed information on the available preseed options.

## Contributing

If you have improvements or fixes for the files on this Repository, feel free to submit a pull request. Contributions are welcome!