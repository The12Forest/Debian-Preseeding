# Debian Preseeding

This repository contains a preseed configuration file (`preseed.cfg`) for automating the installation of Debian Linux.

## What is Preseeding?

Preseeding is a method for automating the Debian installation process. By providing answers to the installation prompts in advance, you can perform unattended installations, which is particularly useful for deploying multiple systems with the same configuration.

## Usage

To use the `preseed.cfg` file for a Debian installation, follow these steps:

1. **Download the Debian Installer ISO**: Obtain the Debian installer ISO from the [official Debian website](https://www.debian.org/distrib/).

2. **Modify the `preseed.cfg`**: Change the password in the Preseedfile how you like it. I recomend a Hash bat you can alsow define it in planetext.

3. **Modify the ISO**: Add the `preseed.cfg` file to the ISO. This can be done using tools like `genisoimage` or `xorriso`.

4. **Boot from the ISO**: Boot the target machine from the modified ISO.

5. **Specify the Preseed File**: When prompted, specify the location of the `preseed.cfg` file. This can be done by appending the following to the boot parameters:
    ```
    auto=true priority=critical file=/cdrom/preseed.cfg
    ```

## Customization

You can customize the `preseed.cfg` file to suit your specific needs. The file contains various settings that control different aspects of the installation process, such as partitioning, package selection, and network configuration.

Refer to the [Debian Installation Guide](https://www.debian.org/releases/stable/amd64/apb.html.en) for detailed information on the available preseed options.

## Other stuff


### Contributing

If you have improvements or fixes for the `preseed.cfg` file, feel free to submit a pull request. Contributions are welcome!

### License

This project is licensed under the MIT License. See the `LICENSE` file for details.