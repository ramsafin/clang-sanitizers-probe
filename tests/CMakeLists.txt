set(TARGET_NAME unit_tests)

add_executable(${TARGET_NAME} test_sanitizers.cpp)

target_link_libraries(${TARGET_NAME} 
  PRIVATE 
    GTest::gtest_main 
    project_warnings 
    project_sanitizers
)

include(GoogleTest)
gtest_discover_tests(unit_tests)
