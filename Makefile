#
# Makefile template for out of tree kernel modules
#

# PetaLinux-related stuff
ifndef PETALINUX
$(error You must source the petalinux/settings.sh script before working with PetaLinux)
endif

-include modules.common.mk

KERNEL_BUILD:=$(PROOT)/build/$(LINUX_KERNEL)

LOCALPWD=$(shell pwd)
obj-m += xlnx-axi-dma-zio.o

ZIO_ABS=$(LOCALPWD)/zio
export ZIO_ABS

GIT_VERSION = $(shell git describe --always --dirty --long --tags)
ZIO_GIT_VERSION = $(shell cd $(ZIO_ABS); git describe --always --dirty --long --tags)
ZIO_VERSION := -D__ZIO_MAJOR_VERSION=$(shell echo $(ZIO_GIT_VERSION) | cut -d '-' -f 2 | cut -d '.' -f 1; )
ZIO_VERSION += -D__ZIO_MINOR_VERSION=$(shell echo $(ZIO_GIT_VERSION) | cut -d '-' -f 2 | cut -d '.' -f 2; )
ZIO_VERSION += -D__ZIO_PATCH_VERSION=$(shell echo $(ZIO_GIT_VERSION) | cut -d '-' -f 3)
export GIT_VERSION
export ZIO_VERSION

all: build modules install

build: modules

.PHONY: build clean modules

clean:
	make INSTANCE=$(LINUX_KERNEL) -C $(KERNEL_BUILD) M=$(ZIO_ABS) clean
	make INSTANCE=$(LINUX_KERNEL) -C $(KERNEL_BUILD) M=$(LOCALPWD) clean

modules:
	if [ ! -f "$(PROOT)/build/$(LINUX_KERNEL)/link-to-kernel-build/Module.symvers" ]; then \
		echo "ERROR: Failed to build module ${INSTANCE} because kernel hasn't been built."; \
		echo "ERROR: Please build kernel with petalinux-build -c kernel first."; \
		exit 255; \
	else \
		make INSTANCE=$(LINUX_KERNEL) -C $(KERNEL_BUILD) M=$(ZIO_ABS) modules_only; \
		make INSTANCE=$(LINUX_KERNEL) -C $(KERNEL_BUILD) M=$(LOCALPWD) modules_only; \
	fi

install: $(addprefix $(DIR),$(subst .o,.ko,$(obj-m)))
	if [ ! -f "$(PROOT)/build/$(LINUX_KERNEL)/link-to-kernel-build/Module.symvers" ]; then \
		echo "ERROR: Failed to install module ${INSTANCE} because kernel hasn't been built."; \
		echo "ERROR: Please build kernel with petalinux-build -c kernel first."; \
		exit 255; \
	else \
		make INSTANCE=$(LINUX_KERNEL) -C $(KERNEL_BUILD) M=$(ZIO_ABS) INSTALL_MOD_PATH=$(TARGETDIR) modules_install_only; \
		make INSTANCE=$(LINUX_KERNEL) -C $(KERNEL_BUILD) M=$(LOCALPWD) INSTALL_MOD_PATH=$(TARGETDIR) modules_install_only; \
	fi


help:
	@echo ""
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE) and install to rootfs host copy"
	@echo "  build                  build subsystem"
	@echo "  install                install built objects to rootfs host copy"

