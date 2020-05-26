add_library(mobile-cv-suite STATIC IMPORTED GLOBAL)

if (ANDROID)
  set(OPENCV_LIB_EXT "a")
  set(PREBUILT_DIR "${CMAKE_CURRENT_LIST_DIR}/build/android")
  set(LIB_DIR "${PREBUILT_DIR}/lib/${ANDROID_ABI}")
else()
  set(OPENCV_LIB_EXT "so")
  set(PREBUILT_DIR "${CMAKE_CURRENT_LIST_DIR}/build/host")
  set(LIB_DIR "${PREBUILT_DIR}/lib")
endif()

set(INC_DIR "${PREBUILT_DIR}/include")
set(INTERFACE_INCLUDES
  ${INC_DIR}
  ${INC_DIR}/eigen3)

set(INTERFACE_LIBS
  # --- static
  ${LIB_DIR}/libamd.a
  ${LIB_DIR}/libbtf.a
  ${LIB_DIR}/libcamd.a
  ${LIB_DIR}/libccolamd.a
  ${LIB_DIR}/libcolamd.a
  ${LIB_DIR}/libcxsparse.a
  #${LIB_DIR}/libdbow2.a
  ${LIB_DIR}/libg2o_core.a
  ${LIB_DIR}/libg2o_solver_csparse.a
  ${LIB_DIR}/libg2o_solver_dense.a
  ${LIB_DIR}/libg2o_solver_eigen.a
  ${LIB_DIR}/libg2o_solver_pcg.a
  ${LIB_DIR}/libg2o_solver_slam2d_linear.a
  ${LIB_DIR}/libg2o_solver_structure_only.a
  ${LIB_DIR}/libg2o_stuff.a
  ${LIB_DIR}/libg2o_types_data.a
  ${LIB_DIR}/libg2o_types_icp.a
  ${LIB_DIR}/libg2o_types_sba.a
  ${LIB_DIR}/libg2o_types_sclam2d.a
  ${LIB_DIR}/libg2o_types_sim3.a
  ${LIB_DIR}/libg2o_types_slam2d.a
  ${LIB_DIR}/libg2o_types_slam2d_addons.a
  ${LIB_DIR}/libg2o_types_slam3d.a
  ${LIB_DIR}/libg2o_types_slam3d_addons.a
  ${LIB_DIR}/libopenblas.a
  ${LIB_DIR}/libjsonl-recorder.a
  ${LIB_DIR}/libsuitesparseconfig.a
  ${LIB_DIR}/libtheia.a
  ${LIB_DIR}/libyaml-cpp.a
  # --- shared
  ${LIB_DIR}/libmetis.so
  ${LIB_DIR}/libg2o_csparse_extension.so
  ${LIB_DIR}/libsuitesparseconfig.so
  # --- opencv
  ${LIB_DIR}/libopencv_videoio.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_video.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_calib3d.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_features2d.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_imgproc.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_imgcodecs.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_flann.${OPENCV_LIB_EXT}
  ${LIB_DIR}/libopencv_core.${OPENCV_LIB_EXT}
)

if (ANDROID)
  list(APPEND INTERFACE_LIBS
    ${LIB_DIR}/libtegra_hal.a
    z) # zlib, required by OpenCV stuff
else()
  find_package(Threads REQUIRED)
  list(APPEND INTERFACE_LIBS
    ${LIB_DIR}/libopencv_highgui.so
    ${LIB_DIR}/libpangolin.so
    ${LIB_DIR}/libloguru.a
    Threads::Threads)

  # Linux needs more libraries for logging
  find_library(DL_LIBRARY NAMES dl)
  if (EXISTS ${DL_LIBRARY})
    message(STATUS "the dl (dynamic linking) library ${DL_LIBRARY} exists, adding it for loguru")
    list(APPEND INTERFACE_LIBS ${DL_LIBRARY})
  endif()

  # not sure why OpenCV likes the folder opencv4/opencv2
  list(APPEND INTERFACE_INCLUDES ${INC_DIR}/opencv4)
endif()

# Fortran may be needed on some platforms.
find_library(GFORTRAN_LIBRARY NAMES gfortran)
if (EXISTS ${GFORTRAN_LIBRARY})
  message(STATUS "gfortan found")
  list(APPEND INTERFACE_LIBS ${GFORTRAN_LIBRARY})
endif()

set_target_properties(mobile-cv-suite PROPERTIES
    IMPORTED_LOCATION "${LIB_DIR}/libdbow2.a" # any library will do
    IMPORTED_LINK_INTERFACE_LIBRARIES "${INTERFACE_LIBS}"
    INTERFACE_INCLUDE_DIRECTORIES "${INTERFACE_INCLUDES}")
