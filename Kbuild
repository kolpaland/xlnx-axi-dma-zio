KBUILD_EXTRA_SYMBOLS := $(ZIO_ABS)/Module.symvers

SUBMODULE_VERSIONS += MODULE_INFO(version_zio,\"$(ZIO_VERSION)\");
ccflags-y += -DADDITIONAL_VERSIONS="$(SUBMODULE_VERSIONS)"

ccflags-y += -I$(ZIO_ABS)/include
ccflags-y += -DGIT_VERSION=\"$(GIT_VERSION)\"
ccflags-y += $(ZIO_VERSION)

obj-m += xlnx-axi-dma-zio.o
