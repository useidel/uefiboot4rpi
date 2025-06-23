# uefiboot4rpi
This will contain some guidance and commands to harmless switch from the traditional [u-boot](https://u-boot.org/) based setup for [Raspbery Pi OS](https://www.raspberrypi.com/software/) to an [UEFI](https://uefi.org/) one (including [Grub](https://www.gnu.org/software/grub/))

## Prologue

Before going into details I want to give a big applause to the people behind the following web pages.

- [Raspberry Pi 4 UEFI Booting](https://community.tmpdir.org/t/raspberry-pi-4-uefi-booting/377)

- [Installing Debian ARM64 on a Raspberry Pi 3 in UEFI mode](https://pete.akeo.ie/2019/07/installing-debian-arm64-on-raspberry-pi.html)

- [Raspberry Pi 4 : Manjaro on UEFI firmware with “Generic” ARM kernel](https://forum.manjaro.org/t/raspberry-pi-4-manjaro-on-uefi-firmware-with-generic-arm-kernel/127589)

The instructions/discussions/text where is the foundation of what I can provide here. Thank you all!!


At the moment it covers only the RaspberryPi 3 and 4 hardware models and assumes that the baseline is the [SD image provided by the Raspberry Pi foundation](https://www.raspberrypi.com/software/operating-systems/).
For Raspberry Pi 5 please scroll to the end of this page.

Here are more details about the assumptions by the script/guidance

1. The OS image of the SD card has 2 partitions, where one contains the the boot information for the Raspberry Pi and is mounted under /boot/firmware once the system is up and running.

````
# fdisk -l  /dev/mmcblk0
....
Device         Boot   Start      End  Sectors  Size Id Type
/dev/mmcblk0p1         8192  1056767  1048576  512M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      1056768 30392319 29335552   14G 83 Linux
# 
# mount|grep /dev/mmcblk0
/dev/mmcblk0p2 on / type ext4 (rw,noatime)
/dev/mmcblk0p1 on /boot/firmware type vfat ...
# 
````

2. The running RaspberryPiOS recognizes the SD as /dev/mmcblk0 or similar (see also above)

3. The system has internet access to download the UEFI firmware files and the package wget installed 

````
wget -nd https://github.com/pftf/RPi4/releases/download/v1.42/RPi4_UEFI_Firmware_v1.42.zip
````

4. Right now the script does not everything for you. You still need to configure the UEFI setup after the first boot. That requires a monitor and keyboard access. 
That includes disabling the 3GB RAM limit, configuring the SystemTable to use "ACPI + DeviceTree" and to configure the default boot option using the file `/boot/efi/EFI/debian/grubaa64.efi`.
In case of more help please check [here](https://forum.manjaro.org/t/raspberry-pi-4-manjaro-on-uefi-firmware-with-generic-arm-kernel/127589)

Sidenote: recent tests on RPi3 look like the settings for RAM and SystemTable are correct and don't need any changes. However, the setup of the boot entry to point Grub seems to be a bit iffy. 

## How to use it?

- Boot you Raspberry Pi with standard SD image. 

- Login and make yourself too `root`. 

- Copy/download the script `enable.uefi.grub.4.rpi4.sh` and simply execute it. You can also execute the steps yourself by simply copying the corresponding lines. 

- Once done, reboot the Raspberry Pi and hit `ESC` to enter the UEFI configuration. Disable the 3GB RAM Limitation and set System Table to  ACPI + DeviceTree.
Select: Device Manager -> Raspberry Pi Configuration -> Advanced Configuration. 
![screenshot](assets/images/uefi.rpi.system.config.jpg "UEFI System Config")
Do not forget to save your changes with "F10".

As said above: this is probably not needed on Raspberry Pi 3 - but x-checking does not harm

Also, add an Boot entry which points to `efi/EFI/debian/grubaa64.efi` on your first partition. Make sure that is entry is the default. And yes, you may want to delete all the other ones. 
Select: Boot Device Manager -> Boot Options and the corresponding sub menus

![screenshot](assets/images/uefi.boot.maint.jpg "UEFI Boot Maintenance")

Again, don't forget to save your changes with "F10". 
Please do check if the boot entry you have created is the default. That seems to be a bit flaky on Raspberry Pi 3. 

This is how it could look like once booted successfully. ;-)

````
# efibootmgr -v
BootCurrent: 0001
Timeout: 5 seconds
BootOrder: 0000,0006,0001
Boot0000* UiApp FvVol(9a15aa37-d555-4a4e-b541-86391ff68164)/FvFile(462caa21-7614-4503-836e-8ab6f4662331)
Boot0001* Grub for RaspberryPi OS       VenHw(100c2cfa-b586-4198-9b4c-1683d195b1da)/HD(1,MBR,0xefb0edee,0x4000,0x100000)/File(\EFI\debian\grubaa64.efi)
Boot0006  UEFI Shell    FvVol(9a15aa37-d555-4a4e-b541-86391ff68164)/FvFile(7c04a583-9e3e-4f1c-ad65-e05268d0b4d1)
# 
````

## What else?

Tested with

- [Official RaspberryPI OS (64bit) (bookworm)](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-64-bit)
- [Tested RaspberryPI Debian Images (64bit) (bookworm, trixie)](https://raspi.debian.net/tested-images/)
- [Armbian for Raspberry Pi](https://www.armbian.com/rpi4b/)

Planned for the future

1. Fully automate the setup -> including the UEFI part
2. Be more flexible regarding the assumptions

Unclear:

RPiv5 seems to be a lost case due to [here](https://github.com/worproject/rpi5-uefi) ... let's keep watching if things change


