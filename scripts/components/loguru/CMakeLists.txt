cmake_minimum_required(VERSION 3.0)
set(LIBNAME loguru)
project(${LIBNAME})

set(CMAKE_CXX_STANDARD 11)

# uncoventional CMakeList.txt pointing outside the current directory
set(LOGURU_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../loguru")
add_library(${LIBNAME} "${LOGURU_SRC_DIR}/loguru.cpp")
set_target_properties(${LIBNAME} PROPERTIES PUBLIC_HEADER "${LOGURU_SRC_DIR}/loguru.hpp")

install(TARGETS ${LIBNAME}
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION include)
