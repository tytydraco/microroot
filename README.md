# MicroRoot
A lightweight glibc rootfs for containers.

# Features
- BusyBox for core utilities
- Reproducible builds (host agnostic)
- Glibc for binary compatibility
- Supports Linux Kernel 4.4.x and newer
- Binutils v2.34
- Built with GCC 10, Link Time Optimization and Graphite
- OPKG package manager
- No default init system
- 1.9 MB compressed XZ tarball

# Philosophy
MicroRoot is heavily inspired by [Alpine Linux](https://alpinelinux.org/), a
distribution built against BusyBox and musl as the C library. As a result,
Alpine Linux provides rootfs tarballs for a variety of architectures at around
2.6 MB when GZIP compressed. Unfortunately, the use of musl as the C library
breaks proprietary binaries that were compiled against glibc, resulting in a
less portable container. MicroRoot attempts to be match the benefits of Alpine
Linux, being lightweight and compressed, while also compiling against glibc.
The finished product is a portable container at almost the same size as Alpine
Linux, with the ability to execute glibc binaries.

# Building
MicroRoot is built using [Buildroot](https://buildroot.org/), a tool for
generating rootfs images for embedded systems. The first step is to download the
latest [Buildroot tarball](https://buildroot.org/download.html) and extract it
to a location on your Linux machine.

Next, download the latest MicroRoot Buildroot defconfig from this repository,
which can be found
[here](https://raw.githubusercontent.com/tytydraco/microroot/master/microroot_defconfig).

Navigate to your extracted buildroot directory, and copy the `microroot_defconfig`
file to the `./configs/` folder.

Now, we need to tell Buildroot to use our configuration file. Type `make
microroot_defconfig`. Since MicroRoot uses a savedefconfig, it should be
compatible across Buildroot versions.

NOTE: The default build target for MicroRoot is x86_64 and corei7. If your
target device requirements differ, head down to [Additional Configuration](#Additional Configuration).
In the menuconfig menu, navigate to Target options and adjust Target
Architecture and Target Architecture Variant to fit your needs.

Finally, it is time to build MicroRoot. Type `make` to start the build process.
This can take anywhere from ten minutes to an hour depending on the speed of
your build system.

Once finished, and confirming that your `make` command did not end in an error
message, your MicroRoot tarball should be located at
`./output/images/rootfs.tar.xz`.

# Additional Configuration
Since MicroRoot is just a custom Buildroot configuration, you have the freedom
to tweak the config file. Type `make menuconfig` to enter the Buildroot
configuration menu. Here, you can enable packages for guest system that were not
initially compiled into MicroRoot. Once finished, save your changes and type
`make` to start your build.

NOTE: For subsequent builds, run `make clean` between builds if you remove an
option. Otherwise, ccache will not remove the option from your final build.

# License
MicroRoot is licensed under GPLv3, which includes the following permissions:

- Ability to use this software for any purpose
- Ability to change the software
- Ability to share the software
- Ability to share changes made to the software

You can read more about GPLv3 [here](https://www.gnu.org/licenses/gpl-3.0.en.html).
