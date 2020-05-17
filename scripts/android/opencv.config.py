"""
OpenCV Android SDK configuration file
"""

def getFlags(armeabi=False, x86=False):
    # NOTE: can be disabled if VideoRecorder is not needed. Also note that
    # FFMpeg, which is LGPL-licensed (with some GPL-licensed codecs) is not
    # included with these settings and consequently only the OpenCV built-in
    # MJPG/AVI codec is supported on Android
    videorecording = 'ON'
    flags = dict(
        # Disable some modules we do not use
        BUILD_opencv_dnn='OFF',
        BUILD_opencv_photo='OFF',
        BUILD_opencv_ml='OFF',
        BUILD_opencv_stitching='OFF',
        BUILD_opencv_objdetect='OFF',
        BUILD_opencv_highgui='OFF',
        BUILD_opencv_videoio=videorecording,
        BUILD_opencv_imgcodecs=videorecording,
        # No Java support needed, all OpenCV operations are done in native code
        BUILD_opencv_java='OFF',
        INSTALL_ANDROID_EXAMPLES='OFF',
        # Disable internal OpenCV parallelism:
        # When assessing the performance of our system, we should be careful not to let OpenCV use
        # too many threads so that some will be left for the user application of this system too.
        # It is possible to control the thread pool size TBB or other frameworks used by OpenCV
        # but if we can do without completely, it would be the safest and most predictable option
        WITH_TBB='OFF',
        WITH_OPENMP='OFF',
        WITH_PTHREADS_PF='OFF',
        # Intel "Instrumentation and Tracing Technology". Not relevant
        # as Android devices do not use Intel processors
        WITH_ITT='OFF',
        # More Intel stuff
        WITH_IPP='OFF',
        # Drop unused image codecs
        WITH_TIFF='OFF',
        WITH_PNG='OFF',
        WITH_JASPER='OFF',
        WITH_JPEG='OFF',
        WITH_WEBP='OFF',
        WITH_OPENEXR='OFF',
        # And other unused features
        WITH_QUIRC='OFF',
        WITH_PROTOBUF='OFF',
        WITH_FFMPEG='OFF')
    if armeabi: flags['ANDROID_ABI'] = 'armeabi-v7a with NEON'
    return flags

ABIs = [
    ABI("2", "armeabi-v7a", None, 21, cmake_vars=getFlags(armeabi=True)),
    ABI("3", "arm64-v8a",   None, 21, cmake_vars=getFlags()),
    ABI("5", "x86_64",      None, 21, cmake_vars=getFlags(x86=True)),
    ABI("4", "x86",         None, 21, cmake_vars=getFlags(x86=True)),
]
