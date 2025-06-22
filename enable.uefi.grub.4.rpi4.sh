#/bin/sh
PATH=/bin:/sbin:/usr/sbin:/usr/sbin
export PATH

# Getting up-to-date
apt update && apt -y upgrade

# now install the needed packages
apt -y install grub2-common grub-efi-arm64-bin grub-efi-arm64 grub-efi-arm64-signed grub-common

# Not sure if we really need the stuff in /boot/firmware but it does not harm to save it
# We will re-use the partition for the EFI setup
umount /boot/firmware
mkdir /tmp/mnt
mount /dev/mmcblk0p1 /tmp/mnt
cd /tmp/mnt
cp -a * /boot/firmware/
sync
cd
umount /tmp/mnt

# Creating the mountpoint for EFI and update the /etc/fstab
mkdir /boot/efi
perl -pi -e 's/firmware/efi/g' /etc/fstab
# You may want to change the mount options as well from "default" -> "noexec,nodev,noatime"

# Your systemd may want be properly be informed about the content change of /etc/fstab
systemctl daemon-reload 

# Now changed the type of partition 1 to "uefi" and also mark it as bootable
# the latter is probably not needed - but does not harm and could be handy for reinstallations
fdisk /dev/mmcblk0 << EOF
a
1
t
1
uefi
w
EOF

# Tell the kernel to reload the new partition table .. just in case
partprobe
# create a filesystem on the EFI partition and mount it
mkfs.fat -n EFI /dev/mmcblk0p1
mount /dev/mmcblk0p1 /boot/efi
# actually a "mount -a" should now work as well

# Get the UEFI firmeware files for the RPiv4 family
cd
wget -nd https://github.com/pftf/RPi4/releases/download/v1.42/RPi4_UEFI_Firmware_v1.42.zip   
# and place it under /boot/efi
cd /boot/efi
unzip /root/RPi4_UEFI_Firmware_v1.42.zip 

# Ok, we need to create that one directory ...
mkdir /boot/efi/EFI

# And now can install grub and automagically create a grub.cfg
grub-install
update-grub

# Thats it - now some config in the UEFI part is still outstanding
