include_guard(GLOBAL)

# --- Options ---
option(ENABLE_ASAN      "Enable address sanitizer"            OFF)
option(ENABLE_UBSAN     "Enable undefined behavior sanitizer" OFF)
option(ENABLE_HARDENING "Enable production hardening"         OFF)

set(TARGET_NAME project_sanitizers)

set(PROJECT_ASAN_FLAGS 
  "-fsanitize=address"
  "-fno-omit-frame-pointer"
  "-fsanitize-address-use-after-scope"
)

set(PROJECT_UBSAN_FLAGS 
  "-fsanitize=undefined"
  "-fno-sanitize-recover=all"
  "-fsanitize=float-divide-by-zero"
)

set(PROJECT_OHOS_HARDENING_FLAGS
  "-fstack-protector-strong"
  "-mbranch-protection=standard"
)

add_library(${TARGET_NAME} INTERFACE)

target_compile_options(${TARGET_NAME} INTERFACE
  $<$<BOOL:${ENABLE_ASAN}>:${PROJECT_ASAN_FLAGS}>
  $<$<BOOL:${ENABLE_UBSAN}>:${PROJECT_UBSAN_FLAGS}>
  $<$<AND:$<PLATFORM_ID:OHOS>,$<BOOL:${ENABLE_HARDENING}>>:${PROJECT_OHOS_HARDENING_FLAGS}>
)

target_link_options(${TARGET_NAME} INTERFACE
  $<$<BOOL:${ENABLE_ASAN}>:-fsanitize=address>
  $<$<BOOL:${ENABLE_UBSAN}>:-fsanitize=undefined>

  # production hardening: relro and bind now
  $<$<BOOL:${ENABLE_HARDENING}>:-Wl,-z,relro;-Wl,-z,now>
)

target_compile_definitions(${TARGET_NAME} INTERFACE
  # Hardening: libc++ assertions and fortify source
  $<$<BOOL:${ENABLE_HARDENING}>:_LIBCPP_ENABLE_ASSERTIONS=1;_FORTIFY_SOURCE=3>
)