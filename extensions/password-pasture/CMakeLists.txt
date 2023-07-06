cmake_minimum_required(VERSION 3.23)
project(password_pasture C)

set(CMAKE_C_STANDARD 17)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK4 REQUIRED gtk4)

include_directories(${GTK4_INCLUDE_DIRS})
link_directories(${GTK4_LIBRARY_DIRS})

add_definitions(${GTK4_CFLAGS_OTHER})

add_executable(password_pasture main.c)

target_link_libraries(password_pasture ${GTK4_LIBRARIES})