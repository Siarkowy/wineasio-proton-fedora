#!/usr/bin/make -f
# Makefile for WineASIO #
# --------------------- #
# Created by falkTX
#

VERSION = 1.1.0

all:
	@echo "error: you must pass '32' or '64' as an argument to this Makefile in order to build WineASIO"

deps:
	sudo dnf install -y gcc make \
		pipewire-jack-audio-connection-kit-devel.i686 \
		pipewire-jack-audio-connection-kit-devel.x86_64 \
		wine-devel.i686 \
		wine-devel.x86_64 \
		glibc-devel.i686

# ---------------------------------------------------------------------------------------------------------------------

32:
	$(MAKE) build ARCH=i386 M=32

64:
	$(MAKE) build ARCH=x86_64 M=64

# ---------------------------------------------------------------------------------------------------------------------

# likely Steam library paths:
# $(HOME)/.steam/steam/steamapps
# /mnt/path/to/SteamLibrary/steamapps
# $(HOME)/.var/app/com.valvesoftware.Steam/data/Steam/steamapps
STEAM_LIBRARY := $(HOME)/.steam/steam/steamapps

PROTON_ROOT := "$(STEAM_LIBRARY)/common/Proton 7.0"
PROTON_WINEPREFIX := "$(STEAM_LIBRARY)/compatdata/221680/pfx"

install: 32 64
	install -v -m755 build32/wineasio.dll $(PROTON_ROOT)/dist/lib/wine/i386-windows/
	install -v -m755 build32/wineasio.dll.so $(PROTON_ROOT)/dist/lib/wine/i386-unix/

	install -v -m755 build64/wineasio.dll $(PROTON_ROOT)/dist/lib64/wine/x86_64-windows/
	install -v -m755 build64/wineasio.dll.so $(PROTON_ROOT)/dist/lib64/wine/x86_64-unix/

	install -v -m644 build32/wineasio.dll $(PROTON_WINEPREFIX)/drive_c/windows/syswow64/
	install -v -m644 build64/wineasio.dll $(PROTON_WINEPREFIX)/drive_c/windows/system32/

register: install
	WINEPREFIX=$(PROTON_WINEPREFIX) $(PROTON_ROOT)/dist/bin/wine regsvr32 $(PROTON_ROOT)/dist/lib/wine/i386-windows/wineasio.dll
	WINEPREFIX=$(PROTON_WINEPREFIX) $(PROTON_ROOT)/dist/bin/wine64 regsvr32 $(PROTON_ROOT)/dist/lib64/wine/x86_64-windows/wineasio.dll

silverblue: # tested with fedora 38
	# required for LD_PRELOAD in 32-bit apps
	rpm-ostree install steam pipewire-jack-audio-connection-kit.i686

# ---------------------------------------------------------------------------------------------------------------------

clean:
	rm -f *.o *.so
	rm -rf build32 build64
	rm -rf gui/__pycache__

# ---------------------------------------------------------------------------------------------------------------------

tarball: clean
	rm -f ../wineasio-$(VERSION).tar.gz
	tar -c -z \
		--exclude=".git*" \
		--exclude=".travis*" \
		--exclude=debian \
		--exclude=prepare_64bit_asio.sh \
		--exclude=rtaudio/cmake \
		--exclude=rtaudio/contrib \
		--exclude=rtaudio/doc \
		--exclude=rtaudio/tests \
		--exclude=rtaudio/"*.ac" \
		--exclude=rtaudio/"*.am" \
		--exclude=rtaudio/"*.in" \
		--exclude=rtaudio/"*.sh" \
		--exclude=rtaudio/"*.txt" \
		--transform='s,^\.,wineasio-$(VERSION),' \
		-f ../wineasio-$(VERSION).tar.gz .

# ---------------------------------------------------------------------------------------------------------------------

ifneq ($(ARCH),)
ifneq ($(M),)
include Makefile.mk
endif
endif

# ---------------------------------------------------------------------------------------------------------------------
