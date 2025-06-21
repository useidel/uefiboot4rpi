# uefiboot4rpi
This will contain some guidance and commands to harmless switch from the traditional [u-boot](https://u-boot.org/) based setup for [Raspbery Pi OS](https://www.raspberrypi.com/software/) to an [UEFI](https://uefi.org/) one (including [Grub](https://www.gnu.org/software/grub/))

Before going into details I want to give a big applause to the people behind the following web pages.

[Raspberry Pi 4 UEFI Booting](https://community.tmpdir.org/t/raspberry-pi-4-uefi-booting/377)

[Installing Debian ARM64 on a Raspberry Pi 3 in UEFI mode](https://pete.akeo.ie/2019/07/installing-debian-arm64-on-raspberry-pi.html)

[Raspberry Pi 4 : Manjaro on UEFI firmware with “Generic” ARM kernel](https://forum.manjaro.org/t/raspberry-pi-4-manjaro-on-uefi-firmware-with-generic-arm-kernel/127589)

The instructions/discussions/text where is the foundation of what I can provide here. Thank you!!

At the moment it covers only the RaspberryPi 4 family (Pi4, Pi400 and Pi4-Compute) and assumes that the baseline is the [SD image provided by the Raspberry Pi foundation](https://www.raspberrypi.com/software/operating-systems/).

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

2. The running RaspberryPiOS recognizes the SD as /dev/mmcblk0 (see also above)

3. The system has internet access to download the UEFI firmware files and the package wget installed 

````
wget -nd https://github.com/pftf/RPi4/releases/download/v1.42/RPi4_UEFI_Firmware_v1.42.zip
````

4. Right now the script does not everything for you. You still need to configure the UEFI setup after the first boot. That requires a monitor and keyboard access. 

Planned for the future

1. Fully automate the setup for RPiv4 - including the UEFI part
2. Be more flexible regarding the assumptions
3. Cover [RPiv3](https://github.com/pftf/RPi3)

Unclear:

RPiv5 seems to be a lost case due to [here](https://github.com/worproject/rpi5-uefi) ... let's keep watching if things change


