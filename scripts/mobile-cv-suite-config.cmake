add_library(mobile-cv-suite::core STATIC IMPORTED GLOBAL)
add_library(mobile-cv-suite STATIC IMPORTED GLOBAL)

# _MCS_ = Mobile CV Suite. Note that CMake variables are global by
# default and will mess up other build scripts on conflicts

if (ANDROID)
  set(_MCS_OPENCV_LIB_EXT "a")
  set(_MCS_PREBUILT_DIR "${CMAKE_CURRENT_LIST_DIR}/build/android")
  set(_MCS_LIBS "${_MCS_PREBUILT_DIR}/lib/${ANDROID_ABI}")
else()
  set(TARGET_ARCH "host" CACHE STRING "Target architecture")
  string(SUBSTRING ${CMAKE_SHARED_LIBRARY_SUFFIX} 1 -1 _MCS_OPENCV_LIB_EXT)
  set(_MCS_PREBUILT_DIR "${CMAKE_CURRENT_LIST_DIR}/build/${TARGET_ARCH}")
  set(_MCS_LIBS "${_MCS_PREBUILT_DIR}/lib")
endif()

set(_MCS_INC "${_MCS_PREBUILT_DIR}/include")
set(_MCS_INTERFACE_INCLUDES
  ${_MCS_INC}
  ${_MCS_INC}/eigen3)

set(_MCS_CORE_INTERFACE_LIBS
  # --- static
  ${_MCS_LIBS}/libtheia.a
  ${_MCS_LIBS}/libaccelerated-arrays.a
  ${_MCS_LIBS}/libyaml-cpp.a
)

# --- opencv
if((DEFINED OpenCV_DIR) AND IOS)
  message("OpenCV iOS framework")
  # Relies on custom "OpenCVConfig.cmake" placed at $OpenCV_DIR.
  find_package(OpenCV 4 REQUIRED PATHS ${OpenCV_DIR})
  list(APPEND _MCS_CORE_INTERFACE_LIBS ${OpenCV_LIBS})
else()
  list(APPEND _MCS_CORE_INTERFACE_LIBS
    ${_MCS_LIBS}/libopencv_videoio.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_video.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_calib3d.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_features2d.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_imgcodecs.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_imgproc.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_flann.${_MCS_OPENCV_LIB_EXT}
    ${_MCS_LIBS}/libopencv_core.${_MCS_OPENCV_LIB_EXT}
  )
endif()

if (EXISTS ${_MCS_LIBS}/libamd.a)
  set(_MCS_USE_SLAM TRUE)
else()
  set(_MCS_USE_SLAM FALSE)
endif()

if (EXISTS ${_MCS_LIBS}/libpangolin.${_MCS_OPENCV_LIB_EXT})
  set(_MCS_INCLUDE_VISUALIZATIONS TRUE)
else()
  set(_MCS_INCLUDE_VISUALIZATIONS FALSE)
endif()

set(_MCS_COMPONENTS mobile-cv-suite::core)
if (_MCS_USE_SLAM)
  add_library(mobile-cv-suite::slam STATIC IMPORTED GLOBAL)
  list(APPEND _MCS_COMPONENTS mobile-cv-suite::slam)
  set(_MCS_SLAM_INTERFACE_LIBS
    # --- static
    ${_MCS_LIBS}/libamd.a
    ${_MCS_LIBS}/libcamd.a
    ${_MCS_LIBS}/libccolamd.a
    ${_MCS_LIBS}/libcolamd.a
    ${_MCS_LIBS}/libdbow2.a
    ${_MCS_LIBS}/libg2o_core.a
    ${_MCS_LIBS}/libg2o_solver_csparse.a
    ${_MCS_LIBS}/libg2o_solver_dense.a
    ${_MCS_LIBS}/libg2o_solver_eigen.a
    ${_MCS_LIBS}/libg2o_solver_pcg.a
    ${_MCS_LIBS}/libg2o_solver_slam2d_linear.a
    ${_MCS_LIBS}/libg2o_solver_structure_only.a
    ${_MCS_LIBS}/libg2o_stuff.a
    ${_MCS_LIBS}/libg2o_types_data.a
    ${_MCS_LIBS}/libg2o_types_icp.a
    ${_MCS_LIBS}/libg2o_types_sba.a
    ${_MCS_LIBS}/libg2o_types_sclam2d.a
    ${_MCS_LIBS}/libg2o_types_sim3.a
    ${_MCS_LIBS}/libg2o_types_slam2d.a
    ${_MCS_LIBS}/libg2o_types_slam2d_addons.a
    ${_MCS_LIBS}/libg2o_types_slam3d.a
    ${_MCS_LIBS}/libg2o_types_slam3d_addons.a
    # --- shared
    # libbtf and cxsparse are LGPL licensed, so they must be used as shared libraries
    ${_MCS_LIBS}/libbtf${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${_MCS_LIBS}/libcxsparse${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${_MCS_LIBS}/libsuitesparseconfig${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${_MCS_LIBS}/libg2o_csparse_extension${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${_MCS_LIBS}/libsuitesparseconfig${CMAKE_SHARED_LIBRARY_SUFFIX})

  if(NOT(IOS))
    if(NOT(ANDROID))
      list(APPEND _MCS_SLAM_INTERFACE_LIBS
        ${_MCS_LIBS}/libmetis${CMAKE_SHARED_LIBRARY_SUFFIX}
      )
    endif()
    if (EXISTS ${_MCS_LIBS}/libopenblas.a)
      list(APPEND _MCS_SLAM_INTERFACE_LIBS
        ${_MCS_LIBS}/libopenblas.a
      )
    else()
      find_package(BLAS)
      list(APPEND _MCS_SLAM_INTERFACE_LIBS ${BLAS_LIBRARIES})
    endif()
  endif()
  set_target_properties(mobile-cv-suite::slam PROPERTIES
          IMPORTED_LOCATION "${_MCS_LIBS}/libjsonl-recorder.a" # any library will do
          IMPORTED_LINK_INTERFACE_LIBRARIES "${_MCS_SLAM_INTERFACE_LIBS}"
          INTERFACE_INCLUDE_DIRECTORIES "${_MCS_INTERFACE_INCLUDES}")
endif()

if (ANDROID)
  list(APPEND _MCS_CORE_INTERFACE_LIBS
    ${_MCS_LIBS}/libtegra_hal.a
    z) # zlib, required by OpenCV stuff
elseif(IOS)
  # iOS stuff here if needed
else()
    # not sure why OpenCV likes the folder opencv4/opencv2
    list(APPEND _MCS_INTERFACE_INCLUDES ${_MCS_INC}/opencv4)

  if (_MCS_INCLUDE_VISUALIZATIONS)
    add_library(mobile-cv-suite::visualization STATIC IMPORTED GLOBAL)
    list(APPEND _MCS_COMPONENTS mobile-cv-suite::visualization)
    find_package(Pangolin REQUIRED PATHS "${_MCS_LIBS}/cmake/Pangolin" NO_DEFAULT_PATH)
    list(APPEND _MCS_INTERFACE_LIBS ${Pangolin_LIBRARIES})
    set_target_properties(mobile-cv-suite::visualization PROPERTIES
            IMPORTED_LOCATION "${_MCS_LIBS}/libjsonl-recorder.a" # any library will do
            IMPORTED_LINK_INTERFACE_LIBRARIES "${Pangolin_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${_MCS_INTERFACE_INCLUDES}")
  endif()

  find_package(Threads REQUIRED)
  list(APPEND _MCS_CORE_INTERFACE_LIBS
    ${_MCS_LIBS}/libopencv_highgui${CMAKE_SHARED_LIBRARY_SUFFIX}
    ${_MCS_LIBS}/libloguru.a
    Threads::Threads)

  # Linux needs more libraries for logging
  find_library(_MCS_DL_LIBRARY NAMES dl)
  if (EXISTS ${_MCS_DL_LIBRARY})
    message(STATUS "the dl (dynamic linking) library ${_MCS_DL_LIBRARY} exists, adding it for loguru")
    list(APPEND _MCS_CORE_INTERFACE_LIBS ${_MCS_DL_LIBRARY})
  endif()
endif()

# Fortran may be needed on some platforms.
find_library(GFORTRAN_LIBRARY NAMES gfortran)
if (EXISTS ${GFORTRAN_LIBRARY})
  message(STATUS "gfortan found")
  list(APPEND _MCS_SLAM_INTERFACE_LIBS ${GFORTRAN_LIBRARY})
endif()

set_target_properties(mobile-cv-suite::core PROPERTIES
    IMPORTED_LOCATION "${_MCS_LIBS}/libjsonl-recorder.a" # any library will do
    IMPORTED_LINK_INTERFACE_LIBRARIES "${_MCS_CORE_INTERFACE_LIBS}"
    INTERFACE_INCLUDE_DIRECTORIES "${_MCS_INTERFACE_INCLUDES}")

set_target_properties(mobile-cv-suite PROPERTIES
        IMPORTED_LOCATION "${_MCS_LIBS}/libjsonl-recorder.a" # any library will do
        IMPORTED_LINK_INTERFACE_LIBRARIES "${_MCS_COMPONENTS}"
        INTERFACE_INCLUDE_DIRECTORIES "${_MCS_INTERFACE_INCLUDES}")
