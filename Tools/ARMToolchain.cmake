include(ExternalProject)

SET(TOOLS_VERSION_SHORT "4.8")
SET(TOOLS_VERSION_LONG "4.8-2014-q1-update")
SET(TOOLS_VERSION_FILENAME "4_8-2014q1-20140314")
SET(TOOLS_EXPANDED_DIRNAME "gcc-arm-none-eabi-4_8-2014q1")

SET(TOOLS_URL_PREFIX "https://launchpad.net/gcc-arm-embedded/${TOOLS_VERSION_SHORT}/${TOOLS_VERSION_LONG}/+download/")

IF(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  SET(TOOLS_SUFFIX "linux.tar.bz2")
ELSEIF(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  SET(TOOLS_SUFFIX "mac.tar.bz2")
ELSEIF(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  SET(TOOLS_SUFFIX "win32.zip")
ELSE()
  MESSAGE(FATAL_ERROR "Unsupported system: ${CMAKE_SYSTEM_NAME}")
ENDIF()

SET(TOOLS_ARCHIVE_NAME "gcc-arm-none-eabi-${TOOLS_VERSION_FILENAME}-${TOOLS_SUFFIX}")
SET(TOOLS_URL "${TOOLS_URL_PREFIX}/${TOOLS_ARCHIVE_NAME}")

IF(NOT IS_DIRECTORY "${CMAKE_SOURCE_DIR}/../Tools/arm-eabi-toolchain")
message("Downloading ARM EABI toolchain from ${TOOLS_URL} ...")
file(DOWNLOAD ${TOOLS_URL} "${CMAKE_SOURCE_DIR}/../Tools/${TOOLS_ARCHIVE_NAME}" SHOW_PROGRESS)
execute_process(COMMAND tar xhjf "${TOOLS_ARCHIVE_NAME}"
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/../Tools/")
file(RENAME "${CMAKE_SOURCE_DIR}/../Tools/${TOOLS_EXPANDED_DIRNAME}" "${CMAKE_SOURCE_DIR}/../Tools/arm-eabi-toolchain")
file(REMOVE "${CMAKE_SOURCE_DIR}/../Tools/{TOOLS_ARCHIVE_NAME}")
ENDIF()

SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_VERSION 1)
SET(CMAKE_C_COMPILER ${PROJECT_SOURCE_DIR}/../Tools/arm-eabi-toolchain/bin/arm-none-eabi-gcc)
SET(CMAKE_CXX_COMPILER ${PROJECT_SOURCE_DIR}/../Tools/arm-eabi-toolchain/bin/arm-none-eabi-g++)
SET(OBJCOPY ${PROJECT_SOURCE_DIR}/../Tools/arm-eabi-toolchain/bin/arm-none-eabi-objcopy)

SET(CMAKE_FIND_ROOT_PATH
  ${PROJECT_SOURCE_DIR}/../Tools/arm-eabi-toolchain/arm-none-eabi/bin
  ${PROJECT_SOURCE_DIR}/../Tools/arm-eabi-toolchain/arm-none-eabi/lib
  ${PROJECT_SOURCE_DIR}/../Tools/arm-eabi-toolchain/arm-none-eabi/include
 )
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Workaround for http://www.cmake.org/Bug/view.php?id=9985
SET(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
SET(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")
