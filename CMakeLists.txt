cmake_minimum_required(VERSION 3.12)

set(PATCH_VERSION "1" CACHE INTERNAL "Patch version")

project(ip_filter VERSION 0.0.${PATCH_VERSION})

add_executable(ip_filter
    src/main.cpp
)

set_target_properties(ip_filter PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
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

include(CPack)