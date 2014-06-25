cmake_minimum_required (VERSION 2.8.7)
project(g2)

include(../Tools/ARMToolchain.cmake)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti -fno-exceptions")
add_definitions("--param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb -mlong-calls")
add_definitions("-ffunction-sections -fdata-sections -nostdlib -Wall -g3 -Os")
add_definitions("-u _printf_float")

# Turn off printf() format strings. We use late bound FLASH and RAM format strings and this causes warnings
add_definitions("-Wno-format-nonliteral -Wno-format-security")

# Turn off unknown pragmas, because MotateUSBHelpers.h have them a lot (why?)
add_definitions("-Wno-unknown-pragmas")

IF(NOT PLATFORM)
  SET(PLATFORM "gShield")
  MESSAGE("Setting default platform: ${PLATFORM}")
  MESSAGE("To configure with a specific platform, use: 'cmake -DPLATFORM=value ..'")
ENDIF()

MESSAGE("PLATFORM: ${PLATFORM}")

IF(PLATFORM STREQUAL "gShield")
  SET(BASE_PLATFORM "due")
  SET(MOTATE_BOARD "gShield")
ELSE(PLATFORM STREQUAL "G2v9g")
  SET(BASE_PLATFORM "v9_3x8c")
  SET(MOTATE_BOARD "G2v9g")
ELSE()
  MESSAGE(FATAL_ERROR "Unknown platform: ${PLATFORM}")
ENDIF()

add_definitions("-DMOTATE_BOARD=${MOTATE_BOARD}")
add_definitions("-DPLATFORM=${PLATFORM}")
add_definitions("-Dflash")

IF(BASE_PLATFORM STREQUAL "due")
  SET(CHIP "SAM3X8E")
  SET(PLATFORM_BASE platform/atmel_sam)
  SET(CMSIS_ROOT CMSIS)
  include_directories(
      CMSIS/Device/ATMEL
      CMSIS/Device/ATMEL/sam3xa/include
      platform/atmel_sam
      platform/atmel_sam/board/due)
ENDIF()

IF(BASE_PLATFORM STREQUAL "v9_3x8c")
  SET(CHIP "SAM3X8C")
  SET(PLATFORM_BASE platform/atmel_sam)
  SET(CMSIS_ROOT CMSIS)
  include_directories(
      CMSIS/Device/ATMEL
      platform/atmel_sam
      CMSIS/Device/ATMEL/sam3xa/include
      platform/atmel_sam/board/v9_3x8c)
ENDIF()

add_definitions("-D__${CHIP}__")
SET(CMAKE_EXE_LINKER_FLAGS "-T ${PROJECT_SOURCE_DIR}/${PLATFORM_BASE}/gcc_flash.ld -Wl,--entry=Reset_Handler")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--check-sections -Wl,--gc-sections")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--cref -Wl,-Map,${PLATFORM}.map")

# Hack for suppressing warnings about 3 missing symbols.
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--defsym=SMC_Handler=0")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--defsym=USART3_Handler=0")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--defsym=EMAC_Handler=0")
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -nostartfiles --specs=nano.specs -u _printf_float -mcpu=cortex-m3 -mthumb")

include_directories(. motate "${CMSIS_ROOT}/CMSIS/Include")

add_executable("${PLATFORM}.elf"
  canonical_machine.cpp
  CMSIS/Device/ATMEL/sam3xa/source/gcc/startup_sam3xa.c
  CMSIS/Device/ATMEL/sam3xa/source/system_sam3xa.c
  config_app.cpp
  config.cpp
  controller.cpp
  cycle_homing.cpp
  cycle_jogging.cpp
  cycle_probing.cpp
  encoder.cpp
  gcode_parser.cpp
  hardware.cpp
  help.cpp
  json_parser.cpp
  kinematics.cpp
  main.cpp
  motate/AvrUSB.cpp
  motate/SamPins.cpp
  motate/SamSPI.cpp
  motate/SamTimers.cpp
  motate/SamUSB.cpp
  persistence.cpp
  plan_arc.cpp
  plan_exec.cpp
  plan_line.cpp
  planner.cpp
  platform/atmel_sam/cortex_handlers.c
  platform/atmel_sam/hooks.c
  platform/atmel_sam/Reset.cpp
  platform/atmel_sam/syscalls_sam3.cpp
  pwm.cpp
  report.cpp
  spindle.cpp
  stepper.cpp
  switch.cpp
  text_parser.cpp
  util.cpp
  xio.cpp)

add_dependencies("${PLATFORM}.elf" arm-eabi-toolchain)

# Generate .bin file
add_custom_command(OUTPUT "${PLATFORM}.bin.tmp"
    COMMAND "${OBJCOPY}" --output-format=binary "${PLATFORM}.elf" "${PLATFORM}.bin.tmp"
    COMMAND ${CMAKE_COMMAND} -E copy "${PLATFORM}.bin.tmp" "${PLATFORM}.bin"
    DEPENDS "${PLATFORM}.elf"
    COMMENT "Generating ${PLATFORM}.bin")

add_custom_target("${PLATFORM}.bin" ALL DEPENDS "${PLATFORM}.bin.tmp")
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${PLATFORM}.bin")

# Generate HEX file
add_custom_command(OUTPUT "${PLATFORM}.hex.tmp"
    COMMAND "${OBJCOPY}" --output-format=ihex "${PLATFORM}.elf" "${PLATFORM}.hex.tmp"
    COMMAND ${CMAKE_COMMAND} -E copy "${PLATFORM}.hex.tmp" "${PLATFORM}.hex"
    DEPENDS "${PLATFORM}.elf"
    COMMENT "Generating ${PLATFORM}.hex")

add_custom_target("${PLATFORM}.hex" ALL DEPENDS "${PLATFORM}.hex.tmp")
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${PLATFORM}.hex")
