cmake_minimum_required(VERSION 3.21)
project(sanitizers LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# exposes "project_sanitizers" interface library
# link against it to use sanitizers
include(sanitizers)

# exposes "project_warnings" interface library
# link against it to use warnings
include(warnings)

# --- dependencies ---
add_subdirectory(contrib)

add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME} 
  PRIVATE project_warnings project_sanitizers
)

if (ENABLE_TESTING)
  enable_testing()
  add_subdirectory(tests)
endif()