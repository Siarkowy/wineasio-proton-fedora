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
