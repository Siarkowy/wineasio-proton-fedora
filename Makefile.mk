#!/usr/bin/make -f
# Makefile for WineASIO #
# --------------------- #
# Created by falkTX
# Initially generated by winemaker
#

ifeq ($(ARCH),)
$(error incorrect use of Makefile, ARCH var is missing)
endif
ifeq ($(M),)
$(error incorrect use of Makefile, M var is missing)
endif

wineasio_dll_MODULE   = wineasio.dll

PREFIX                = /usr
SRCDIR                = .
DLLS                  = $(wineasio_dll_MODULE) $(wineasio_dll_MODULE).so

### Tools

CC        = gcc
WINEBUILD = winebuild
WINECC    = winegcc

ifeq ($(M),64)
PKG_CONFIG_PATH = /usr/lib$(M)/pkgconfig
else
PKG_CONFIG_PATH = /usr/lib/pkgconfig
endif
export PKG_CONFIG_PATH

### Common settings

CEXTRA                = -m$(M) -D_REENTRANT -fPIC -Wall -pipe
CEXTRA               += -fno-strict-aliasing -Wdeclaration-after-statement -Wwrite-strings -Wpointer-arith
CEXTRA               += -Werror=implicit-function-declaration
CEXTRA               += $(shell pkg-config --cflags jack)
RCEXTRA               =
INCLUDE_PATH          = -I. -Irtaudio/include
INCLUDE_PATH         += -I$(PREFIX)/include/wine
INCLUDE_PATH         += -I$(PREFIX)/include/wine/windows
INCLUDE_PATH         += -I$(PREFIX)/include/wine-development
INCLUDE_PATH         += -I$(PREFIX)/include/wine-development/wine/windows
INCLUDE_PATH         += -I/opt/wine-stable/include
INCLUDE_PATH         += -I/opt/wine-stable/include/wine/windows
INCLUDE_PATH         += -I/opt/wine-staging/include
INCLUDE_PATH         += -I/opt/wine-staging/include/wine/windows
LIBRARIES             = $(shell pkg-config --libs jack)

# 64bit build needs an extra flag
ifeq ($(M),64)
CEXTRA               += -DNATIVE_INT64
endif

# Debug or Release
ifeq ($(DEBUG),true)
CEXTRA               += -O0 -DDEBUG -g -D__WINESRC__
else
CEXTRA               += -O2 -DNDEBUG -fvisibility=hidden
endif

### wineasio.dll settings

wineasio_dll_C_SRCS   = asio.c \
			main.c \
			regsvr.c
wineasio_dll_LDFLAGS  = -shared \
			-m$(M) \
			-mnocygwin \
			$(wineasio_dll_MODULE:%=%.spec) \
			-L/usr/lib$(M)/wine \
			-L/usr/lib/wine \
			-L/usr/lib/$(ARCH)-linux-gnu/wine \
			-L/usr/lib/$(ARCH)-linux-gnu/wine-development \
			-L/opt/wine-stable/lib \
			-L/opt/wine-stable/lib/wine \
			-L/opt/wine-stable/lib$(M) \
			-L/opt/wine-stable/lib$(M)/wine \
			-L/opt/wine-staging/lib \
			-L/opt/wine-staging/lib/wine \
			-L/opt/wine-staging/lib$(M) \
			-L/opt/wine-staging/lib$(M)/wine
wineasio_dll_DLLS     = odbc32 \
			ole32 \
			winmm
wineasio_dll_LIBRARIES = uuid

wineasio_dll_OBJS     = $(wineasio_dll_C_SRCS:%.c=build$(M)/%.c.o)

### Global source lists

C_SRCS                = $(wineasio_dll_C_SRCS)

### Generic targets

all:
build: rtaudio/include/asio.h $(DLLS:%=build$(M)/%)

### Build rules

.PHONY: all

# Implicit rules

build$(M)/%.c.o: %.c
	@$(shell mkdir -p build$(M))
	$(CC) -c $(INCLUDE_PATH) $(CFLAGS) $(CEXTRA) -o $@ $<

### Target specific build rules

build$(M)/$(wineasio_dll_MODULE): $(wineasio_dll_OBJS)
	$(WINEBUILD) -m$(M) --dll --fake-module -E $(wineasio_dll_MODULE).spec $^ -o $@

build$(M)/$(wineasio_dll_MODULE).so: $(wineasio_dll_OBJS)
	$(WINECC) $^ $(wineasio_dll_LDFLAGS) $(LIBRARIES) \
		$(wineasio_dll_DLLS:%=-l%) $(wineasio_dll_LIBRARIES:%=-l%) -o $@
