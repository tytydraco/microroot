#!/usr/bin/env bash

# Navigate to this directory
cd `dirname "$0"`

# Output directory for building
OUT="./out"
DEFCONFIG_URL="https://raw.githubusercontent.com/tytydraco/microroot/master/microroot_defconfig"

# Log in red and exit
err() {
	echo -e " \e[91m*\e[39m $@"
	exit 1
}

# Log in white and continue (unnecessary)
dbg() {
	echo -e " \e[92m*\e[39m $@"
}

# Clear the entire build directory
clean() {
	dbg "Removing Buildroot instance..."
	rm -rf ./out
}

# Create and enter an output directory
prepare() {
	dbg "Preparing output directory..."
	mkdir -p ./out
	cd ./out
}

# Return the directory name of the Buildroot
get_buildroot_name() {
	ls -d buildroot*/ 2> /dev/null | head -n 1
}

# Pull the latest stable Buildroot (not LTS, not snapshot)
setup_buildroot() {
	if [[ ! -z `get_buildroot_name` ]]
	then
		dbg "Buildroot already exists. Skipping setup..."
		return 0
	fi

	local latest=`curl -s https://buildroot.org/download.html |
		grep images/zip | uniq | sed -n '2 p' | awk -F \" '{ print $2 }'`
	local url="https://buildroot.org/$latest"

	dbg "Pulling $url..."
	curl -Lso buildroot.tar.gz "$url"

	dbg "Extracting Buildroot..."
	tar xf buildroot.tar.gz 
}

# Navigate to and enter Buildroot
enter_buildroot() {
	dbg "Querying for Buildroot..."
	local br_dir=`get_buildroot_name`

	[[ -z "$br_dir" ]] && err "Buildroot missing. Exiting."

	dbg "Entering $br_dir..."
	cd "$br_dir"
}

# Fetch microroot_defconfig
setup_defconfig() {
	dbg "Fetching latest MicroRoot defconfig..."
	curl -Ls "$DEFCONFIG_URL" > configs/microroot_defconfig
}

# Clean the buildroot directory and make config
prepare_buildroot() {
	dbg "Cleaning Buildroot..."
	make clean > /dev/null

	dbg "Updating local config..."
	make microroot_defconfig > /dev/null
}

# Build the rootfs using Buildroot
build() {
	dbg "Building..."
	make

	[[ $? -ne 0 ]] && err "Build failed. Exiting."

	local br_dir=`get_buildroot_name`

	dbg "---------- FINISHED ----------"
	dbg "./out/$br_dir/output/images/rootfs.tar.xz"
	dbg "------------------------------"
}

# Check for required dependencies
for dep in bc cd cpio curl g++ gcc grep make mkdir python3 rsync tar unzip wget
do
	! command -v "$dep" &> /dev/null && err "Unable to locate dependency $dep. Exiting."
done

# Detect manual clean command
if [[ "$1" == "clean" ]]
then
	clean
	exit 0
fi

prepare
setup_buildroot
enter_buildroot
setup_defconfig
prepare_buildroot
build
