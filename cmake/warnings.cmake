include_guard(GLOBAL)

option(ENABLE_WARNINGS "Compiler warnings" ON)
option(WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

set(TARGET_NAME project_warnings)

set(PROJECT_COMMON_WARNINGS
  -Wall
  -Wextra
  -Wpedantic
  -Wshadow                 # Warn if a variable shadows one from an outer scope
  -Wunused                 # Warn on unused variables/functions
  -Wformat=2               # Enhanced printf/scanf checking
  -Wnull-dereference       # Detect potential null pointer access
  -Wcast-align             # Warn on pointer casts that increase alignment
  -Wdouble-promotion       # Warn when a float is implicitly promoted to double
  -Wimplicit-fallthrough   # Require [[fallthrough]] in switch statements
  -Wmisleading-indentation # Warn if indentation doesn't match block structure
)

set(PROJECT_CXX_WARNINGS
  ${PROJECT_COMMON_WARNINGS}
  -Wold-style-cast         # Prefer static_cast<int>(x) over (int)x
  -Wnon-virtual-dtor       # Ensure base classes have virtual destructors
  -Woverloaded-virtual     # Warn if a function hides a virtual function
  -Wconversion             # Warn on type conversions that lose data
  -Wsign-conversion        # Warn on sign-related type conversions
  -Wextra-semi             # Warn on unnecessary semicolons
)

add_library(${TARGET_NAME} INTERFACE)

target_compile_options(${TARGET_NAME} INTERFACE
  $<$<BOOL:${ENABLE_WARNINGS}>:
    # lang-specific warnings
    $<$<COMPILE_LANGUAGE:CXX>:${PROJECT_CXX_WARNINGS}>
    $<$<COMPILE_LANGUAGE:C>:${PROJECT_COMMON_WARNINGS}>
    
    # treat warnings as errors
    $<$<BOOL:${WARNINGS_AS_ERRORS}>:-Werror>
  >
)