#
# Copyright (C) 2017 unixjet <unixjet@hotmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk


BOARDS:= \
	nuc972-evb

loadaddr-y := 0x00008000

VMLINUX:=$(IMG_PREFIX)-vmlinux
UIMAGE:=$(IMG_PREFIX)-uImage

define Image/Build/Initramfs
	$(call Image/Build/Profile/$(PROFILE),initramfs)
endef

#
# The real magic happens inside these templates
#
# $(1), compression method
# $(2), filename of image data
# $(3), output filename
define MkImage
	mkimage -A ARM -O linux -T kernel -C $(1) -a $(loadaddr-y) -e $(loadaddr-y) \
		-n 'ARM OpenWrt Linux-$(LINUX_VERSION)' \
		-d $(2) $(3)
endef

define CompressLzma
	$(STAGING_DIR_HOST)/bin/lzma e $(1) -lc1 -lp2 -pb2 $(2)
endef


# $(1), lowercase board name like "mt7620a_v22sg"
# $(2), DTS filename without .dts extension
# $(3), optional filename suffix, e.g. "-initramfs"
#	cp $(KDIR)/vmlinux$(3) $(KDIR)/vmlinux-$(1)$(3)
#	$(call Image/BuildDTB,../dts/$(2).dts,$(KDIR)/$(2).dtb)
#	$(STAGING_DIR_HOST)/bin/patch-dtb $(KDIR)/vmlinux-$(1)$(3) $(KDIR)/$(2).dtb
#	$(call CompressLzma,$(KDIR)/vmlinux-$(1)$(3),$(KDIR)/vmlinux-$(1)$(3).bin.lzma)
#	$(call Image/BuildDTB,../dts/$(2).dts,$(KDIR)/$(2).dtb)
define PatchKernelLzmaDtb
	echo 'PatchKernelLzmaDtb'
	cp ../dts/nuc970.dtsi $(LINUX_DIR)/arch/arm/boot/dts/
	cp ../dts/$(2).dts $(LINUX_DIR)/arch/arm/boot/dts/
	$(call Image/BuildDTB,$(LINUX_DIR)/arch/arm/boot/dts/$(2).dts,$(KDIR)/$(2).dtb)
	cat $(LINUX_DIR)/arch/arm/boot/zImage $(KDIR)/$(2).dtb > $(KDIR)/zImageDtb
endef

# $(1), lowercase board name
# $(2), DTS filename without .dts extension
# $(3), ih_name field of uImage header
# $(4), optional filename suffix, e.g. "-initramfs"
#	$(call MkImage,lzma,$(KDIR)/zImageDtb,$(KDIR)/$(1).uImage)
define MkImageLzmaDtb
	$(call PatchKernelLzmaDtb,$(1),$(2),$(4))
	$(call MkImage,none,$(KDIR)/zImageDtb,$(KDIR)/$(1).uImage)
	cp $(KDIR)/$(1).uImage $(BIN_DIR)/$(1).uImage
endef

define MkImageSysupgrade/squashfs
	$(eval output_name=$(IMG_PREFIX)-$(2)-$(1)-$(if $(4),$(4),sysupgrade).bin)
	cat $(KDIR)/$(2).uImage $(KDIR)/root.$(1) > $(KDIR)/$(output_name)
	$(call prepare_generic_squashfs,$(KDIR)/$(output_name))
	if [ `stat -c%s "$(KDIR)/$(output_name)"` -gt $(3) ]; then \
		echo "Warning: $(KDIR)/$(output_name) is too big" >&2; \
	else \
		$(CP) $(KDIR)/$(output_name) $(BIN_DIR)/$(output_name); \
	fi
endef

# $(1), Rootfs type, e.g. squashfs
# $(2), lowercase board name
# $(3), DTS filename without .dts extension
# $(4), maximum size of sysupgrade image
# $(5), uImage header's ih_name field
define BuildFirmware/OF
	echo 'BuildFirmware'
	$(call MkImageLzmaDtb,$(2),$(3),$(5))
	$(call MkImageSysupgrade/$(1),$(1),$(2),$(4),$(6))
endef

# $(1), squashfs/initramfs
# $(2), lowercase board name
# $(3), DTS filename without .dts extension
# $(4), ih_name field of uImage header
define BuildFirmware/OF/initramfs
	$(call MkImageLzmaDtb,$(2),$(3),$(4),-initramfs)
endef

# Build images for default ralink layout for 4MB flash
# kernel + roots = 0x3b0000
# $(1) = squashfs/initramfs
# $(2) = lowercase board name
# $(3) = dts file
nuc970_default_fw_size_4M=3866624
BuildFirmware/Default4M/squashfs=$(call BuildFirmware/OF,$(1),$(2),$(3),$(ralink_default_fw_size_4M),$(4))
BuildFirmware/Default4M/initramfs=$(call BuildFirmware/OF/initramfs,$(1),$(2),$(3),$(4))

# Build images for default ralink layout for 8MB flash
# kernel + roots = 0x7b0000
# $(1) = squashfs/initramfs
# $(2) = lowercase board name
# $(3) = dts file
# $(4) = uImage header name field
nuc970_default_fw_size_8M=8060928
BuildFirmware/Default8M/squashfs=$(call BuildFirmware/OF,$(1),$(2),$(3),$(ralink_default_fw_size_8M),$(4))
BuildFirmware/Default8M/initramfs=$(call BuildFirmware/OF/initramfs,$(1),$(2),$(3),$(4))
BuildFirmware/Tplink/squashfs=$(call BuildFirmware/OF/tplink,$(1),$(2),$(3),$(4))
BuildFirmware/Tplink/initramfs=$(call BuildFirmware/OF/tplink/initramfs,$(1),$(2),$(3),$(4))

nuc970_default_fw_size_16M=14680064
BuildFirmware/Default16M/squashfs=$(call BuildFirmware/OF,$(1),$(2),$(3),$(nuc970_default_fw_size_16M),$(4))
BuildFirmware/Default16M/initramfs=$(call BuildFirmware/OF/initramfs,$(1),$(2),$(3),$(4))

nuc970_default_fw_size_32M=33226752
BuildFirmware/Default32M/squashfs=$(call BuildFirmware/OF,$(1),$(2),$(3),$(nuc970_default_fw_size_32M),$(4))
BuildFirmware/Default32M/initramfs=$(call BuildFirmware/OF/initramfs,$(1),$(2),$(3),$(4))


# the last nuc972: dts file name without dts extension
Image/Build/Profile/nuc972=$(call BuildFirmware/Default16M/$(1),$(1),nuc972,nuc972)


ifndef TARGET_DEVICES
#	cp $(KDIR)/vmlinux.elf $(BIN_DIR)/$(VMLINUX).elf
#	cp $(KDIR)/vmlinux $(BIN_DIR)/$(VMLINUX).bin
#	$(call CompressLzma,$(KDIR)/vmlinux,$(KDIR)/vmlinux.bin.lzma)
#	$(call MkImage,lzma,$(KDIR)/vmlinux.bin.lzma,$(KDIR)/uImage.lzma)
#	cp $(KDIR)/uImage.lzma $(BIN_DIR)/$(UIMAGE).bin
define Image/BuildKernel
	echo 'BuildKernel, DO NOTHING'
endef

#	cp $(KDIR)/vmlinux-initramfs.elf $(BIN_DIR)/$(VMLINUX)-initramfs.elf
#	cp $(KDIR)/vmlinux-initramfs $(BIN_DIR)/$(VMLINUX)-initramfs.bin
#	$(call CompressLzma,$(KDIR)/vmlinux-initramfs,$(KDIR)/vmlinux-initramfs.bin.lzma)
#	$(call MkImage,lzma,$(KDIR)/vmlinux-initramfs.bin.lzma,$(KDIR)/uImage-initramfs.lzma)
#	cp $(KDIR)/uImage-initramfs.lzma $(BIN_DIR)/$(UIMAGE)-initramfs.bin
#	$(call Image/Build/Initramfs)
define Image/BuildKernel/Initramfs
	echo 'BuildKernel/Initramfs'
	cp ../dts/nuc970.dtsi $(LINUX_DIR)/arch/arm/boot/dts/
	cp ../dts/nuc972.dts $(LINUX_DIR)/arch/arm/boot/dts/
	$(call Image/BuildDTB,$(LINUX_DIR)/arch/arm/boot/dts/nuc972.dts,$(KDIR)/nuc972.dtb)
	cat $(LINUX_DIR)/arch/arm/boot/zImage $(KDIR)/nuc972.dtb > $(KDIR)/zImageDtb
	$(call MkImage,none,$(KDIR)/zImageDtb,$(KDIR)/nuc972.uImage)
	cp $(KDIR)/nuc972.uImage $(BIN_DIR)/$(IMG_PREFIX)-nuc972-initramfs.bin
endef

define Image/Build
	$(call Image/Build/$(1))
	dd if=$(KDIR)/root.$(1) of=$(BIN_DIR)/$(IMG_PREFIX)-root.$(1) bs=128k conv=sync
	echo 'BuildProfile'
	$(call Image/Build/Profile/$(PROFILE),$(1))
endef
endif 


#define Image/Build/Profile
#	$(if $(CONFIG_TARGET_ROOTFS_INITRAMFS),$(call Image/Build/Profile/$(1),initramfs))
#	$(call Image/Build/Profile/$(1),$(2))
#endef

$(eval $(call BuildImage))
