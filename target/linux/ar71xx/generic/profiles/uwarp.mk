#
# Copyright (C) 2014 PIKA Technologies Inc.
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/UWARP8MB
	NAME:=UWARP8MB
	PACKAGES:=kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-usbdev \
	kmod-usb-storage kmod-fs-vfat kmod-nls-cp437 \
	kmod-nls-iso8859-1 kmod-nls-utf8 kmod-ledtrig-netdev udev
	KCONFIG:= \
		CONFIG_ATH79_MACH_UWARP_AR7420=y \
		CONFIG_ATH79_MACH_UWARP_SPI_16M=n \
		CONFIG_ATH79_MACH_UWARP_SPI_8M=y
endef

define Profile/UWARP8MB/Description
	Package set optimized for the PIKA Technologies uWARP with 8MB memory.
endef

$(eval $(call Profile,UWARP8MB))

define Profile/UWARP16MB
	NAME:=UWARP16MB
	PACKAGES:=kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-usbdev \
	kmod-usb-storage kmod-fs-vfat kmod-nls-cp437 \
	kmod-nls-iso8859-1 kmod-nls-utf8 kmod-ledtrig-netdev udev 
	KCONFIG:= \
		CONFIG_ATH79_MACH_UWARP_AR7420=y \
		CONFIG_ATH79_MACH_UWARP_SPI_16M=y \
		CONFIG_ATH79_MACH_UWARP_SPI_8M=n
endef

define Profile/UWARP16MB/Description
	Package set optimized for the PIKA Technologies uWARP with 16MB memory.
endef

$(eval $(call Profile,UWARP16MB))

