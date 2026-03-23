cmake_minimum_required(VERSION 3.12)

set(PATCH_VERSION "1" CACHE INTERNAL "Patch version")

project(ip_filter VERSION 0.0.${PATCH_VERSION})

add_library(ip_filter_lib
    src/ip_address.cpp
    src/ip_filter.cpp
)

set_target_properties(ip_filter_lib PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_include_directories(ip_filter_lib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

add_executable(ip_filter
    src/main.cpp
)

set_target_properties(ip_filter PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
)

target_link_libraries(ip_filter
    ip_filter_lib
)

if (MSVC)
    target_compile_options(ip_filter PRIVATE /W4)
else ()
    target_compile_options(ip_filter PRIVATE
        -Wall
        -Wextra
        -Wpedantic
        -Werror
    )
endif()

install(TARGETS ip_filter RUNTIME DESTINATION bin)

set(CPACK_GENERATOR DEB)

set(CPACK_PACKAGE_NAME ip_filter)

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

set(CPACK_PACKAGE_CONTACT "d.v.bogomaz@gmail.com")

enable_testing()

# -----------------------------
# GoogleTest (FetchContent)
# -----------------------------
include(FetchContent)

set(BUILD_GMOCK OFF)
set(INSTALL_GTEST OFF)

FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

FetchContent_MakeAvailable(googletest)

# -----------------------------
# GoogleTest target
# -----------------------------
add_executable(ip_filter_gtest
    tests/gtest/ip_filter_test.cpp
)

target_link_libraries(ip_filter_gtest
    ip_filter_lib
    GTest::gtest_main
)

include(GoogleTest)

gtest_discover_tests(ip_filter_gtest)

include(CPack)