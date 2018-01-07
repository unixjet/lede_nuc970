#
# Copyright (C) 2017 unixjet <unixjet@hotmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=nuc970
BOARDNAME:=Nuvoton NUC972 Board
FEATURES:=ext4 rtc usb gpio
CPU_TYPE:=arm926ej-s

MAINTAINER:=unixjet <unixjet@hotmail.com>
KERNEL_PATCHVER:=4.4
KERNELNAME:=zImage dtbs

define Target/Description
	Support for Nuvoton NUC970 boards
endef

include $(INCLUDE_DIR)/target.mk

$(eval $(call BuildTarget))
