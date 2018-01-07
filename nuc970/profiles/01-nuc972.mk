#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/nuc972
  NAME:=NUC972 boards
  FEATURES+=usbd usbhost gpio
  PACKAGES+= \

endef

define Profile/nuc972/Description
	nuvoton NUC972 devices
endef

$(eval $(call Profile,nuc972))
