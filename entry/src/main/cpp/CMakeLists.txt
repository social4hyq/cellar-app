cmake_minimum_required(VERSION 3.5)
project(cellar_bridge)

add_library(cellar_bridge SHARED cellar_bridge.c)

target_include_directories(cellar_bridge PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
  $ENV{OHOS_NATIVE_SYSROOT}/usr/include/napi
  $ENV{OHOS_NATIVE_SYSROOT}/usr/include
)

set_target_properties(cellar_bridge PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/libs/${OHOS_ARCH}
)
