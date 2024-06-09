include(cmake/PlatformDetect.cmake)

if (NOT ${PROJECT_NAME} STREQUAL ${CMAKE_PROJECT_NAME})
    set(GEODE_TARGET_PLATFORM GEODE_TARGET_PLATFORM PARENT_SCOPE)
endif()

if (GEODE_TARGET_PLATFORM STREQUAL "iOS")
    # since geode does not set these, I will manually set them!
    execute_process(COMMAND xcrun --show-sdk-path --sdk iphoneos
    OUTPUT_VARIABLE GEODE_IOS_SDK
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # execute_process(COMMAND xcrun --sdk iphoneos --find clang
    #     OUTPUT_VARIABLE CMAKE_C_COMPILER
    #     OUTPUT_STRIP_TRAILING_WHITESPACE
    # )
    # execute_process(COMMAND xcrun --sdk iphoneos --find clang++
    #     OUTPUT_VARIABLE CMAKE_CXX_COMPILER
    #     OUTPUT_STRIP_TRAILING_WHITESPACE
    # )
    message(STATUS "iOS c++ compiler: ${CMAKE_CXX_COMPILER}")
    set(CMAKE_OSX_ARCHITECTURES arm64)
    set(CMAKE_OSX_SYSROOT ${GEODE_IOS_SDK})
    set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")
    set(CMAKE_SYSTEM_NAME "iOS")

    # this fails on ios builds
    set(BUILD_MD2HTML_EXECUTABLE "OFF")

    # camila, why did you not set GEODE_IOS_SDK anywhere
    set_target_properties(${PROJECT_NAME} PROPERTIES
        SYSTEM_NAME iOS
        OSX_SYSROOT ${GEODE_IOS_SDK}
        OSX_ARCHITECTURES arm64
    )

    target_link_libraries(${PROJECT_NAME} INTERFACE
        "-framework OpenGLES"
          "-framework GLKit"
            "-framework UIKit"
              "-framework WebKit"
        "-framework AVFoundation"
          "-framework CoreFoundation"
            "-framework Foundation"
              "-framework CoreGraphics"
        #"-framework Cocoa"
        ${GEODE_LOADER_PATH}/include/link/ios/libcurl.a
        #${GEODE_LOADER_PATH}/include/link/libfmod.dylib
    )

    target_compile_definitions(${PROJECT_NAME} INTERFACE
        -DCommentType=CommentTypeDummy
    )

    set(GEODE_OUTPUT_NAME "Geode.ios")
    set(GEODE_PLATFORM_BINARY "Geode.ios.dylib")
    set(GEODE_MOD_BINARY_SUFFIX ".ios.dylib" CACHE STRING "" FORCE)
elseif (GEODE_TARGET_PLATFORM STREQUAL "MacOS")

    set_target_properties(${PROJECT_NAME} PROPERTIES
        SYSTEM_NAME MacOS
        APPLE_SILICON_PROCESSOR x86_64
    )

	# for some reason, this value is initialized as an empty string by default. idk why
	if (NOT DEFINED CMAKE_OSX_ARCHITECTURES OR CMAKE_OSX_ARCHITECTURES STREQUAL "")
		set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")
	endif()

    # only exists as a global property
    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.15)

    find_package(CURL REQUIRED)

    target_include_directories(${PROJECT_NAME} INTERFACE
        ${CURL_INCLUDE_DIR}
    )

	target_link_libraries(${PROJECT_NAME} INTERFACE
		"-framework Cocoa"
		"-framework OpenGL"
		"-framework SystemConfiguration"
		${GEODE_LOADER_PATH}/include/link/macos/libfmod.dylib
		${GEODE_LOADER_PATH}/include/link/macos/libssl.a
		${GEODE_LOADER_PATH}/include/link/macos/libcrypto.a
		${GEODE_LOADER_PATH}/include/link/macos/libnghttp2.a
		${GEODE_LOADER_PATH}/include/link/macos/libngtcp2.a
		${GEODE_LOADER_PATH}/include/link/macos/libnghttp3.a
		${GEODE_LOADER_PATH}/include/link/macos/libngtcp2_crypto_boringssl.a
		${GEODE_LOADER_PATH}/include/link/macos/libcurl.a
	)

    target_compile_definitions(${PROJECT_NAME} INTERFACE
        -DCommentType=CommentTypeDummy
        -DGL_SILENCE_DEPRECATION
    )

    set(GEODE_OUTPUT_NAME "Geode")
    set(GEODE_PLATFORM_BINARY "Geode.dylib")
    set(GEODE_MOD_BINARY_SUFFIX ".dylib" CACHE STRING "" FORCE)
elseif (GEODE_TARGET_PLATFORM STREQUAL "Win32")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        SYSTEM_NAME Win32
        GENERATOR_PLATFORM x86
    )

    target_compile_definitions(${PROJECT_NAME} INTERFACE NOMINMAX)

	target_link_libraries(${PROJECT_NAME} INTERFACE 
		${GEODE_LOADER_PATH}/include/link/win64/libcocos2d.lib
		${GEODE_LOADER_PATH}/include/link/win64/libExtensions.lib
		${GEODE_LOADER_PATH}/include/link/win64/ssl.lib
		${GEODE_LOADER_PATH}/include/link/win64/crypto.lib
		${GEODE_LOADER_PATH}/include/link/win64/nghttp2.lib
		${GEODE_LOADER_PATH}/include/link/win64/ngtcp2.lib
		${GEODE_LOADER_PATH}/include/link/win64/nghttp3.lib
		${GEODE_LOADER_PATH}/include/link/win64/ngtcp2_crypto_boringssl.lib
		${GEODE_LOADER_PATH}/include/link/win64/libcurl.lib
		${GEODE_LOADER_PATH}/include/link/win64/glew32.lib
		${GEODE_LOADER_PATH}/include/link/win64/gdstring.lib
		${GEODE_LOADER_PATH}/include/link/win64/fmod.lib
		opengl32
	)

    # Windows links against .lib and not .dll
    set(GEODE_OUTPUT_NAME "Geode")
    set(GEODE_PLATFORM_BINARY "Geode.lib")
    set(GEODE_MOD_BINARY_SUFFIX ".dll" CACHE STRING "" FORCE)
elseif (GEODE_TARGET_PLATFORM STREQUAL "Android32")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        SYSTEM_NAME Android
    )

	target_link_libraries(${PROJECT_NAME} INTERFACE
		c
		${GEODE_LOADER_PATH}/include/link/android32/libssl.a
		${GEODE_LOADER_PATH}/include/link/android32/libcrypto.a
		${GEODE_LOADER_PATH}/include/link/android32/libnghttp2.a
		${GEODE_LOADER_PATH}/include/link/android32/libngtcp2.a
		${GEODE_LOADER_PATH}/include/link/android32/libnghttp3.a
		${GEODE_LOADER_PATH}/include/link/android32/libngtcp2_crypto_boringssl.a
		${GEODE_LOADER_PATH}/include/link/android32/libcurl.a
		${GEODE_LOADER_PATH}/include/link/android32/libcocos2dcpp.so
		${GEODE_LOADER_PATH}/include/link/android32/libfmod.so
		GLESv2
		log
	)

    set(GEODE_OUTPUT_NAME "Geode.android32")
    set(GEODE_PLATFORM_BINARY "Geode.android32.so")
    set(GEODE_MOD_BINARY_SUFFIX ".android32.so" CACHE STRING "" FORCE)
elseif (GEODE_TARGET_PLATFORM STREQUAL "Android64")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        SYSTEM_NAME Android
    )

	target_link_libraries(${PROJECT_NAME} INTERFACE
		c
		${GEODE_LOADER_PATH}/include/link/android64/libssl.a
		${GEODE_LOADER_PATH}/include/link/android64/libcrypto.a
		${GEODE_LOADER_PATH}/include/link/android64/libnghttp2.a
		${GEODE_LOADER_PATH}/include/link/android64/libngtcp2.a
		${GEODE_LOADER_PATH}/include/link/android64/libnghttp3.a
		${GEODE_LOADER_PATH}/include/link/android64/libngtcp2_crypto_boringssl.a
		${GEODE_LOADER_PATH}/include/link/android64/libcurl.a
		${GEODE_LOADER_PATH}/include/link/android64/libcocos2dcpp.so
		${GEODE_LOADER_PATH}/include/link/android64/libfmod.so
		GLESv2
		log
	)

    set(GEODE_OUTPUT_NAME "Geode.android64")
    set(GEODE_PLATFORM_BINARY "Geode.android64.so")
    set(GEODE_MOD_BINARY_SUFFIX ".android64.so" CACHE STRING "" FORCE)
else()
    message(FATAL_ERROR "Unknown platform ${GEODE_TARGET_PLATFORM}")
endif()
