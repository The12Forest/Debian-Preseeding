# Debian Preseeding

This repository contains preseed configuration files (`preseedServer.cfg`, `preseedDesktop.cfg`, `preseedUndefined.cfg`) for automating the installation of Debian Linux.

## What is Preseeding?

Preseeding is a method for automating the Debian installation process. By providing answers to the installation prompts in advance, you can perform unattended installations, which is particularly useful for deploying multiple systems with the same configuration.

## Usage



1. **Download the script**: Obtain the script using:

    ``sudo git clone https://github.com/The12Forest/Debian-Preseeding.git``.

2. **Execute the Script**: Make the sript executable and then RUN it. Using:

    ``sudo chmod +x Compileiso.sh``

    ``sudo ./Compileiso.sh``
3. **Copy the ISO to a USB Drive**: Copy the ISO to a USB Drive using Rufus or Balena etcher.

4. **Boot from the ISO**: Boot the target machine from the modified ISO.

5. **Specify the Preseed File**: When prompted, chose the type of instalation you want to make.

## Customization

You can customize the `preseedServer.cfg`/`preseedDesktop.cfg`/`preseedUndefined.cfg` file to suit your specific needs. The file contains various settings that control different aspects of the installation process, such as partitioning, package selection, and network configuration.

Refer to the [Debian Installation Guide](https://www.debian.org/releases/stable/amd64/apb.html.en) for detailed information on the available preseed options.

## Contributing

If you have improvements or fixes for the files on this Repository, feel free to submit a pull request. Contributions are welcome!