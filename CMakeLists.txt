cmake_minimum_required(VERSION 3.21)
project(sanitizers LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(contrib)

add_executable(${PROJECT_NAME} src/main.cpp)

# Enable sanitizers based on cache variables
if (ENABLE_ASAN)
  target_compile_options(${PROJECT_NAME} PRIVATE 
    -fsanitize=address 
    -fno-omit-frame-pointer
    -fsanitize-address-use-after-scope
  )
  target_link_options(${PROJECT_NAME} PRIVATE -fsanitize=address)
endif()

if (ENABLE_UBSAN)
  target_compile_options(${PROJECT_NAME} PRIVATE 
    -fsanitize=undefined
    -fno-sanitize-recover=all
    -fsanitize=float-divide-by-zero
  )
  target_link_options(${PROJECT_NAME} PRIVATE -fsanitize=undefined)
endif()

if (ENABLE_TESTING)
  enable_testing()
  add_subdirectory(tests)
endif(ENABLE_TESTING)