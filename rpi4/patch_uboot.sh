
deploy_uboot() {

	sudo pacman -S git base-devel swig python dtc
	git clone https://source.denx.de/u-boot/u-boot.git
	cd u-boot
	
	sudo pacman -S aarch64-linux-gnu-gcc
	make distclean
	export CROSS_COMPILE=aarch64-linux-gnu-
	${CROSS_COMPILE}gcc --version

	make rpi_4_defconfig
	make -j$(nproc)
	
		

}
