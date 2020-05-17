# Manually written hack to make find_package(OpenCV) work on iOS install which
# does not include this file.

SET(OpenCV_VERSION 4.1.1)
SET(OpenCV_VERSION_MAJOR  4)
SET(OpenCV_VERSION_MINOR  1)
SET(OpenCV_VERSION_PATCH  1)
SET(OpenCV_VERSION_TWEAK  0)
SET(OpenCV_VERSION_STATUS "")

set(OpenCV_INCLUDE_DIR "${OpenCV_DIR}/include")
set(OpenCV_INCLUDE_DIRS "${OpenCV_INCLUDE_DIR}")
list(APPEND OpenCV_LIBS "${OpenCV_DIR}/../../../opencv2.framework")
include_directories("${OpenCV_INCLUDE_DIR}")

set(OpenCV_FOUND 1)
