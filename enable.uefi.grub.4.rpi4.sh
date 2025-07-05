#/bin/sh
PATH=/bin:/sbin:/usr/sbin:/usr/sbin
export PATH

# ATM we focus on Raspberry Pi hardware only
# instead of /proc one can also use sysfs -> /sys/firmware/devicetree/base/model
grep Raspberry /proc/device-tree/model > /dev/null
if [ $? -ne 0 ]
then
	echo " Does not look like we are an Raspberry Pi hardware"
	echo " Please x-check"
	echo " Fading away for now"
	exit 1
fi

# Pseude devices which should not cause harm
# but also help to not destroy anything 
MYPIHW=1
MYUEFIFWLINK=""
MYUEFIFW=""
MYDEV=/dev/MYDEV
MYPART1=`echo $MYDEV|sed 's/$/p1/g'`

# Are we on Debian'ish
which apt > /dev/null 
if [ $? -ne 0 ]
then
	echo " We are very likely not on the right operating system"
	echo " Better to bail out now"
	exit 1
fi

# some more checks
mount|grep 'boot/firmware' > /dev/null 
if [ $? -ne 0 ]
then
	echo " Something is not right here"
	echo " Safe exit here"
	exit 1
else
	MYPART1=`mount|grep 'boot/firmware' |awk '{print $1}'`
	MYDEV=`echo $MYPART| sed 's/p1$//'`
fi

# which PI HW model do we have?
# only 3 and 4 are supported
MYPIHW=`cat /proc/device-tree/model | strings | grep Raspberry | awk '{print $3}'`
case $MYPIHW in
	3)
	MYUEFIFWLINK=https://github.com/pftf/RPi3/releases/download/v1.39/RPi3_UEFI_Firmware_v1.39.zip
	;;
	4|400)
	MYUEFIFWLINK=https://github.com/pftf/RPi4/releases/download/v1.42/RPi4_UEFI_Firmware_v1.42.zip
	;;
	*)
	echo " This hardware model - $MYPIHW - is not supported"
	exit 1
	;;
esac

MYUEFIFW=`basename $MYUEFIFWLINK`

# Getting up-to-date
apt update && apt -y upgrade

# install wget and unzip for downloading and unpacking the efi firmware files
apt -y install wget unzip

# now install the needed packages for the actual boot
apt -y install grub2-common grub-efi-arm64-bin grub-efi-arm64 grub-efi-arm64-signed grub-common

# Not sure if we really need the stuff in /boot/firmware but it does not harm to save it
# We will re-use the partition for the EFI setup
umount /boot/firmware
mkdir /tmp/mnt
mount $MYPART1 /tmp/mnt
cd /tmp/mnt
cp -a * /boot/firmware/
sync
cd
umount /tmp/mnt

# Now changed the type of partition 1 to "uefi" and also mark it as bootable
# the latter is probably not needed - but does not harm and could be handy for reinstallations
fdisk $MYDEV << EOF
a
1
t
1
uefi
w
EOF

# Tell the kernel to reload the new partition table .. just in case
partprobe
# create a filesystem on the EFI partition 
mkfs.fat -n EFI $MYPART1

# Creating the mountpoint for EFI and make a backup of the /etc/fstab
cp /etc/fstab /etc/fstab.ORIG
mkdir /boot/efi
# if the fstab uses filesystem labels instead of devices
grep 'boot/firmware' /etc/fstab |grep LABEL > /dev/null
if [ $? -eq 0 ]
then
	grep -v 'boot/firmware' /etc/fstab > /tmp/myfstab
	grep 'boot/firmware' /etc/fstab | sed 's/LABEL=.[A-Z]* /LABEL=EFI /' >> /tmp/myfstab
	cp /tmp/myfstab /etc/fstab
fi
# and changing the mountpoint ... after all that fs label stuff
perl -pi -e 's/firmware/efi/g' /etc/fstab
# You may want to change the mount options as well from "default" -> "noexec,nodev,noatime"

# Your systemd may want be properly be informed about the content change of /etc/fstab
systemctl daemon-reload 

# mount the EFI filesystem
mount $MYPART1 /boot/efi
# actually a "mount -a" should now work as well

# Get the UEFI firmeware files for the RPiv4 family
cd
wget -nd $MYUEFIFWLINK
# and place it under /boot/efi
cd /boot/efi
unzip /root/$MYUEFIFW

# Ok, we need to create that one directory ...
mkdir /boot/efi/EFI

# And now can install grub and automagically create a grub.cfg
grub-install
update-grub

# Thats it - now some config in the UEFI part is still outstanding
