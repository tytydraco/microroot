# MicroRoot
A lightweight glibc rootfs for containers.

# Features
- BusyBox for core utilities
- Reproducible builds (host agnostic)
- Glibc for binary compatibility
- Supports Linux Kernel 4.4.x and newer
- Binutils v2.34
- Built with GCC 10, Link Time Optimization, and Graphite
- Tiny compressed XZ tarball

# Philosophy
MicroRoot is heavily inspired by [Alpine Linux](https://alpinelinux.org/), a distribution built against BusyBox and musl as the C library. As a result, Alpine Linux provides rootfs tarballs for a variety of architectures at around 2.6 MB when GZIP compressed. Unfortunately, the use of musl as the C library breaks proprietary binaries that were compiled against glibc, resulting in a less portable container. MicroRoot attempts to match the benefits of Alpine Linux, being lightweight and compressed, while also compiling against glibc. The finished product is a portable container at comparable size to Alpine Linux, with the ability to execute glibc binaries.

# Building
You'll need some initial dependencies for building MicroRoot. The command below is for apt based distributions. The exact system this was tested on was an Ubuntu 20.04.1 chroot. The command below can easily be adapted for other package managers.

`apt-get install bc cpio curl g++ gcc libelf-dev libssl-dev make ncurses-dev python3 rsync unzip wget`

## Build Script Method
MicroRoot comes with a build script to automate the build process of MicroRoot. Simply clone this repository and run the build script with `./build.sh`. The script will handle everything for you.

## Manual Method
MicroRoot is built using [Buildroot](https://buildroot.org/), a tool for generating rootfs images for embedded systems. The first step is to download the latest [Buildroot tarball](https://buildroot.org/download.html) and extract it to a location on your Linux machine.

Next, download the latest MicroRoot Buildroot defconfig from this repository, which can be found [here](https://raw.githubusercontent.com/tytydraco/microroot/master/microroot_defconfig).

Navigate to your extracted buildroot directory, and copy the `microroot_defconfig` file to the `./configs/` folder.

Now, we need to tell Buildroot to use our configuration file. Type `make microroot_defconfig`. Since MicroRoot uses a savedefconfig, it should be compatible across Buildroot versions.

NOTE: The default build target for MicroRoot is x86_64 and corei7. If your target device requirements differ, head down to [Additional Configuration](#additional-configuration). In the menuconfig menu, navigate to Target options and adjust Target Architecture and Target Architecture Variant to fit your needs.

Finally, it is time to build MicroRoot. Type `make` to start the build process. This can take anywhere from ten minutes to an hour depending on the speed of your build system.

Once finished, and confirming that your `make` command did not end in an error message, your MicroRoot tarball should be located at `./output/images/rootfs.tar.xz`.

# Additional Configuration
Since MicroRoot is just a custom Buildroot configuration, you have the freedom to tweak the config file. Enter the Buildroot directory in `./out/buildroot-<version>/`. If your Buildroot folder is not there, either run the build script, or refer to the manual build method. Type `make menuconfig` to enter the Buildroot configuration menu. Here, you can enable packages for system that were not initially compiled into MicroRoot. Once finished, save your changes and type `make` to start your build.

NOTE: For subsequent builds, run `make clean` between builds if you remove an option. Otherwise, ccache will not remove the option from your final build.

# Flashing
MicroRoot comes bundled with GRUBv2 guest utilities and the latest Linux Kernel image. If you are using the build script, your final images are located in `./out/dist`, where you will find `rootfs.tar.xz` and `bzImage`. If you are using the manual build method, your images will be located in `./out/buildroot-<version>/output/images/`.

Partition your drive with the following configuration for the UEFI and GPT scheme:

| Partition 	| Type  	| Size 	| File System 	|
|-----------	|-------	|------	|-------------	|
| /dev/sdX1 	| EFI   	| 512M 	| fat32       	|
| /dev/sdX2 	| Linux 	| *    	| ext4        	|

Next, mount your root partition to a directory of your choice.

`mount /dev/sdX2 /mnt`

Now, extract your generated rootfs tarball to your mounted root partition. We want to copy our kernel image to our boot directory as well. Since GRUBv2 is preconfigured to detect `vmlinuz` images, we should name our kernel image accordingly.

`tar xf /path/to/microroot/out/dist/rootfs.tar.xz -C /mnt`

`cp /path/to/microroot/out/dist/bzImage /mnt/boot/vmlinuz-linux`

We need to mount a few host partitions so that the GRUBv2 utilities are able to see your efivars.

`mount --bind /dev /mnt/dev`

`mount --bind /sys /mnt/sys`

`mount --bind /proc /mnt/proc`

Enter your newly created rootfs partition.

`chroot /mnt`

Since we did not technically use a login shell, we should source `/etc/profile` to setup our PATH environment variable.

`source /etc/profile`

Now, we can begin setting up GRUBv2. We need to mount our EFI partition to our boot directory.

`mkdir /boot/efi`

`mount /dev/sdX1 /boot/efi`

Install GRUBv2 to our EFI partition. Replace `x86_64-efi` with the proper architecture for your scenario.

`grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB`

Create the GRUBv2 configuration file to detect your kernel image and initialize a menu entry.

`grub-mkconfig -o /boot/grub/grub.cfg`

If all is well, you should be able to unmount your drive and boot from it.

`exit`

`umount /mnt/dev`

`umount /mnt/sys`

`umount /mnt/proc`

`umount /mnt/boot/efi`

`umount /mnt`

# License
MicroRoot is licensed under GPLv3, which includes the following permissions:

- Ability to use this software for any purpose
- Ability to change the software
- Ability to share the software
- Ability to share changes made to the software

You can read more about GPLv3 [here](https://www.gnu.org/licenses/gpl-3.0.en.html).
