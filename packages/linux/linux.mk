include $(BASE)/../common/env.mk

linux/VERSION := 5.10.65
linux/TARBALL := https://mirrors.aliyun.com/linux-kernel/v5.x/linux-$(linux/VERSION).tar.xz
linux/dir = $(BUILD)/linux/linux-$(linux/VERSION)

define linux/prepare :=
	+cd $(linux/dir)
	+source $(TOY_WORK)/../../packages/linux/helper.sh && do_patch && do_cfg && do_custom
endef

define linux/build :=
	+cd $(linux/dir)
	+$(MAKE) ARCH=$(ARCH) defconfig
	if [ $(INITRD) -eq  1 ]; then
		sed -i 's/# CONFIG_BLK_DEV_RAM is not set/CONFIG_BLK_DEV_RAM=y/' .config
		sed -i '/CONFIG_BLK_DEV_RAM=y/a\CONFIG_BLK_DEV_RAM_COUNT=16'  .config
		sed -i '/CONFIG_BLK_DEV_RAM=y/a\CONFIG_BLK_DEV_RAM_SIZE=4096' .config
	fi

	+$(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- $(IMG) modules dtbs -j 8
	if [ $(WITH_PERF) -eq  1 ]; then
		+$(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- tools/perf
	fi
	if [ $(WITH_CUSTOM_KO) -eq  1 ]; then
		+cd $(linux/dir)/../custom/
		+$(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- 
	fi
endef

define linux/install :=
	+cd $(linux/dir)/
	+cp arch/$(ARCH)/boot/$(IMG) $(HOST)/
	+cp arch/$(ARCH)/boot/dts/$(DTB) $(HOST)/
	+$(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- INSTALL_MOD_PATH=$(HOST)/sysroot/usr INSTALL_MOD_STRIP=1 modules_install
	+$(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- INSTALL_HDR_PATH=$(HOST)/sysroot/usr headers_install
	if [ $(WITH_PERF) -eq  1 ]; then
		+cd tools && $(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- prefix=$(HOST)/sysroot/usr/ perf_install
	fi
	if [ $(WITH_CUSTOM_KO) -eq  1 ]; then
		+cd $(linux/dir)/../custom/
		+$(CROSS_ENV_RAW) $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_NAME)- INSTALL_MOD_PATH=$(HOST)/sysroot/usr install
	fi
endef

