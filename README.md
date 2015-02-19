# What's this

Linux boot loader for UEFI environment

# How to use it

1. Build kernel not to use initrd

2. Write kernel cmdline in Options variable in myloader.c

3. Make

4. Put your kernel (its name as a vmlinuz) and SimpleMyLoader.efi in EFI System Partition root directory

5. Boot with SimpleMyLoader

# Attention

this program is depend on gnu-efi library

# LICENSE

This software is released under the 2-clause BSD license, see COPYING
