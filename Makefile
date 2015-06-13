ARCH		= x86_64
EFIROOT 	= /usr
HDDRROOT	= $(EFIROOT)/include/efi
INCLUDES	= -I. -I$(HDDRROOT) -I$(HDDRROOT)/$(ARCH)	-I$(HDDRROOT)/protocol

CRTOBJS		= $(EFIROOT)/lib/crt0-efi-$(ARCH).o
CFLAGS		= -O2 -fPIC -Wall -fshort-wchar -fno-strict-aliasing -fno-merge-constants -mno-red-zone
ifeq ($(ARCH),x86_64)
	CFLAGS += -DEFI_FUNCTION_WRAPPER
endif

CPPFLAGS	= -DCONFIG_$(ARCH)
FORMAT		= efi-app-$(ARCH)
INSTALL		= install
LDFLAGS		= -nostdlib
LDSCRIPT	= $(EFIROOT)/lib/elf_$(ARCH)_efi.lds
LDFLAGS	   += -T $(LDSCRIPT) -shared -Bsymbolic -L$(EFIROOT)/lib $(CRTOBJS)
LOADLIBS	= -lefi -lgnuefi $(shell $(CC) -print-libgcc-file-name)

prefix		=
CC			= $(prefix)gcc
AS			= $(prefix)as
LD			= $(prefix)ld
AR			= $(prefix)ar
RANLIB		= $(prefix)ranlib
OBJCOPY		= $(prefix)objcopy

CN_NAME		= John Doe

%.efi: %.so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel \
			   -j .rela -j .reloc --target=$(FORMAT) $*.so $@

%.so: %.o
	$(LD) $(LDFLAGS) $^ -o $@ $(LOADLIBS)

%.o: %.c
	$(CC) $(INCLUDES) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

TARGETS = myloader.efi
KEY = MOK.key MOK.crt
CERT = MOK.cer

all: $(TARGETS)

sign: $(CERT) $(TARGETS)
	sbsign --key MOK.key --cert MOK.crt $(TARGETS)

$(CERT): $(KEY)
	openssl x509 -in MOK.crt -out MOK.cer -outform DER

$(KEY):
	openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt -nodes -days 3650 -subj "/CN=$(CN_NAME)/"

clean:
	rm -f $(TARGETS) $(TARGETS).signed

clean_key:
	rm -f $(KEY) $(CERT)
