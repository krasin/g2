#!/bin/bash

set -ue

arm-none-eabi-gdb ./bin/gShield/gShield_flash.elf -ex "target remote localhost:51234"

