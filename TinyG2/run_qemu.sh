#!/bin/bash

set -ue

# Start QEMU
qemu-system-arm -M versatilepb -S -nographic -monitor null -semihosting  -kernel ./bin/gShield/gShield_flash.elf -gdb tcp::51234 -S

# To connect with GDB:
# (from the different terminal)
# arm-none-eabi-gdb ./bin/gShield/gShield_flash.elf
# (gdb) target remote localhost:51234
