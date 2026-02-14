add_executable(unit_tests test_sanitizers.cpp)
target_link_libraries(unit_tests GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(unit_tests)

# Enable sanitizers based on cache variables
if (ENABLE_ASAN)
  target_compile_options(unit_tests PRIVATE 
    -fsanitize=address 
    -fno-omit-frame-pointer
    -fsanitize-address-use-after-scope
  )
  target_link_options(unit_tests PRIVATE -fsanitize=address)
endif()

if (ENABLE_UBSAN)
  target_compile_options(unit_tests PRIVATE 
    -fsanitize=undefined
    -fno-sanitize-recover=all
    -fsanitize=float-divide-by-zero
  )
  target_link_options(unit_tests PRIVATE -fsanitize=undefined)
endif()