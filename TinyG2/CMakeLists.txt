cmake_minimum_required (VERSION 2.8.9)
project(g2)

include(ExternalProject)

SET(TOOLS_VERSION_SHORT "4.8")
SET(TOOLS_VERSION_LONG "4.8-2014-q1-update")
SET(TOOLS_VERSION_FILENAME "4_8-2014q1-20140314")
SET(TOOLS_EXPANDED_DIRNAME "gcc-arm-none-eabi-4_8-2014q1")

SET(TOOLS_URL_PREFIX "https://launchpad.net/gcc-arm-embedded/${TOOLS_VERSION_SHORT}/${TOOLS_VERSION_LONG}/+download/")

message("TOOLS_VERSION_SHORT: [${TOOLS_VERSION_SHORT}]")
message("TOOLS_URL_PREFIX: [${TOOLS_URL_PREFIX}]")

ExternalProject_Add(arm-eabi-toolchain
  PREFIX arm-none-eabi
  URL ${TOOLS_URL_PREFIX}/gcc-arm-none-eabi-${TOOLS_VERSION_FILENAME}-linux.tar.bz2
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  )

SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_C_COMPILER ${PROJECT_BINARY_DIR}/arm-none-eabi/src/arm-eabi-toolchain/bin/arm-none-eabi-gcc)
SET(CMAKE_CXX_COMPILER ${PROJECT_BINARY_DIR}/arm-none-eabi/src/arm-eabi-toolchain/bin/arm-none-eabi-g++)

SET(CMAKE_FIND_ROOT_PATH
  ${PROJECT_BINARY_DIR}/arm-none-eabi/src/arm-eabi-toolchain/arm-none-eabi/bin
  ${PROJECT_BINARY_DIR}/arm-none-eabi/src/arm-eabi-toolchain/arm-none-eabi/lib
  ${PROJECT_BINARY_DIR}/arm-none-eabi/src/arm-eabi-toolchain/arm-none-eabi/include
  )
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99")
add_definitions("--param max-inline-insns-single=500 -mcpu=cortex-m3 -mthumb -mlong-calls
    -ffunction-sections -fdata-sections -nostdlib -Wall")

# Turn off printf() format strings. We use late bound FLASH and RAM format strings and this causes warnings
add_definitions("-Wno-format-nonliteral -Wno-format-security")

# Turn off unknown pragmas, because MotateUSBHelpers.h have them a lot (why?)
add_definitions("-Wno-unknown-pragmas")

IF(NOT PLATFORM)
  MESSAGE("Setting default platform.")
  SET(PLATFORM "gShield")
ENDIF()

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
  include_directories(CMSIS/Device/ATMEL platform/atmel_sam/board/v9_3x8c)
ENDIF()

add_definitions("-D__${CHIP}__")

SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)

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
  hello.c
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

