#---------------------------------------------------------------------------------
# PACKAGE is the directory where final published files will be placed
#---------------------------------------------------------------------------------
PACKAGE		:=	Package

#---------------------------------------------------------------------------------
# Goals for Build
#---------------------------------------------------------------------------------
.PHONY: GBARunner2 nds-bootstrap TWiLightMenu all clean package_prepare package_dsi package_3ds

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
all: package_dsi package_3ds

build/: 
	mkdir -p build

GBARunner2: gbarunner2_arm7dldi_dsi gbarunner2_arm7dldi_3ds # gbarunner2_arm9dldi_ds gbarunner2_arm7dldi_ds

gbarunner2_arm9dldi_ds: build/
	make -C GBARunner2 clean all
	mv GBARunner2/GBARunner2.nds build/GBARunner2_arm9dldi_ds.nds

gbarunner2_arm7dldi_ds: build/
	make -C GBARunner2 clean all ARM7_DLDI=1
	mv GBARunner2/GBARunner2.nds build/GBARunner2_arm7dldi_ds.nds

gbarunner2_arm7dldi_dsi: build/
	make -C GBARunner2 clean all ARM7_DLDI=1 USE_DSI_16MB=1
	mv GBARunner2/GBARunner2.nds build/GBARunner2_arm7dldi_dsi.nds

gbarunner2_arm7dldi_3ds: build/
	make -C GBARunner2 clean all ARM7_DLDI=1 USE_3DS_32MB=1
	mv GBARunner2/GBARunner2.nds build/GBARunner2_arm7dldi_3ds.nds

NDS_BOOTSTRAP_COMMIT_TAG := $(shell cd nds-bootstrap; git log --format=%h -1)make

nds-bootstrap: build/
	make -C nds-bootstrap package-nightly
	echo ${NDS_BOOTSTRAP_COMMIT_TAG} > build/nightly-bootstrap.ver
	mv nds-bootstrap/bin/b4ds-nightly.nds build/b4ds-nightly.nds
	mv nds-bootstrap/bin/nds-bootstrap-nightly.nds build/nds-bootstrap-nightly.nds
	mv nds-bootstrap/bin/nds-bootstrap-hb-nightly.nds build/nds-bootstrap-hb-nightly.nds

CIATOOL := "TWiLightMenu/booter/make_cia"
TWiLightMenu_COMMIT_TAG_7 := $(shell cd nds-bootstrap; git rev-parse --short=7 HEAD)
TWiLightMenu_COMMIT_TAG_16 := $(shell cd nds-bootstrap; git rev-parse --short=16 HEAD)

TWiLightMenu:
	make -C TWiLightMenu package

	chmod +x ${CIATOOL}
	${CIATOOL} --srl="TWiLightMenu/booter/booter.nds" --id_0=${TWiLightMenu_COMMIT_TAG_7} --tikID=${TWiLightMenu_COMMIT_TAG_16}
	cp TWiLightMenu/booter/booter.cia "TWiLightMenu/7zfile/3DS - CFW users/TWiLight Menu.cia"

	${CIATOOL} --srl="TWiLightMenu/rungame/rungame.nds" --id_0=${TWiLightMenu_COMMIT_TAG_7} --tikID=${TWiLightMenu_COMMIT_TAG_16}
	cp TWiLightMenu/rungame/rungame.cia "TWiLightMenu/7zfile/3DS - CFW users/TWiLight Menu - Game booter.cia"

	cp -r TWiLightMenu/7zfile build/7zfile

package_prepare: GBARunner2 nds-bootstrap TWiLightMenu
	cp build/GBARunner2_arm7dldi_3ds.nds build/7zfile/_nds/GBARunner2_arm7dldi_3ds.nds
	cp build/GBARunner2_arm7dldi_dsi.nds build/7zfile/_nds/GBARunner2_arm7dldi_dsi.nds
	# cp build/GBARunner2_arm9dldi_ds.nds "build/7zfile/Flashcard users/_nds/GBARunner2_arm9dldi_ds.nds"
	# cp build/GBARunner2_arm7dldi_ds.nds "build/7zfile/Flashcard users/_nds/GBARunner2_arm7dldi_ds.nds"

	cp build/nightly-bootstrap.ver build/7zfile/_nds/TWiLightMenu/nightly-bootstrap.ver
	cp build/b4ds-nightly.nds build/7zfile/Flashcard\ users/_nds/b4ds-nightly.nds
	cp build/nds-bootstrap-nightly.nds build/7zfile/_nds/nds-bootstrap-nightly.nds
	cp build/nds-bootstrap-hb-nightly.nds build/7zfile/DSi\&3DS\ -\ SD\ card\ users/_nds/nds-bootstrap-hb-nightly.nds

package_dsi: package_prepare
	mkdir -p ${PACKAGE}
	mkdir -p ${PACKAGE}/NDSI

	cp -r build/7zfile/_nds ${PACKAGE}/NDSI/
	cp -r build/7zfile/DSi\ -\ CFW\ users/SDNAND\ root/* ${PACKAGE}/NDSI/
	cp -r build/7zfile/DSi\&3DS\ -\ SD\ card\ users/_nds ${PACKAGE}/NDSI/
	cp -r build/7zfile/roms ${PACKAGE}/NDSI/

	cp build/7zfile/BOOT.NDS ${PACKAGE}/NDSI/
	cp build/7zfile/AP-patched\ games.txt ${PACKAGE}/NDSI/_nds/

package_3ds: package_prepare
	mkdir -p ${PACKAGE}
	mkdir -p ${PACKAGE}/3DS

	cp -r build/7zfile/_nds ${PACKAGE}/3DS/
	cp -r build/7zfile/3DS\ -\ CFW\ users/* ${PACKAGE}/3DS/
	cp -r build/7zfile/DSi\&3DS\ -\ SD\ card\ users/_nds ${PACKAGE}/3DS/
	cp -r build/7zfile/roms ${PACKAGE}/3DS/

	cp build/7zfile/BOOT.NDS ${PACKAGE}/3DS/
	cp build/7zfile/AP-patched\ games.txt ${PACKAGE}/3DS/_nds/

clean:
	make -C GBARunner2 clean
	make -C nds-bootstrap clean
	make -C TWiLightMenu clean
	rm -rf build ${PACKAGE}
	