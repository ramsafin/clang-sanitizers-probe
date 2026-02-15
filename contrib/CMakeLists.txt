include(FetchContent)

if(ENABLE_TESTING)
  FetchContent_Declare(googletest
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    URL file://${CMAKE_SOURCE_DIR}/contrib/archives/googletest-1.17.0.tar.gz
  )

  set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

  FetchContent_MakeAvailable(googletest)
endif()