# Clang Sanitizers

Sanitizers are **runtime tools** that instrument your code during compilation to catch bugs like memory leaks, data races, and undefined behavior. They are primarily used in testing and CI/CD because they introduce significant performance overhead (2x–15x), though certain "hardening" variants can be adapted for production.

---

## Clang Sanitizer Overview

Clang provides several specialized sanitizers, each targeting a specific category of programming errors.

| Sanitizer | Flags | Detects | Typical Overhead |
| :---      | :--- | :--- | :--- |
| **ASan**  | `-fsanitize=address` | Memory leaks, buffer overflows, use-after-free, double-free | ~2x slower |
| **LSan**  | `-fsanitize=leak` | Memory leaks (often integrated into ASan) | Minimal |
| **TSan**  | `-fsanitize=thread` | Data races between multiple threads | 5x–15x slower |
| **UBSan** | `-fsanitize=undefined` | Null pointers, integer overflows, invalid casts | ~1.2x slower |
| **MSan**  | `-fsanitize=memory` | Reads from uninitialized memory | ~3x slower |

> **Note:** `ASan` and `TSan` are generally **incompatible**. You must create separate test binaries for each build configuration.

---

## Testing and CI/CD Pipelines

It is a best practice to run your entire unit test suite through **ASan** and **UBSan** in your CI pipeline.

* **Compilation Flags:** Use `-g` for debug symbols and `-fno-omit-frame-pointer` to get **readable stack traces** when an error is found.
* **Optimizations:** Use `-O1` or `-O2` with sanitizers so the tests run at a reasonable speed. While `-O0` provides the most accurate line numbers, it can make the instrumented binary too slow for large test suites.

---

## Debug vs. Production Usage

### Debug Builds

Sanitizers can sometimes make interactive debugging (like using **GDB** or **LLDB**) slower or more complex because the "shadow memory" used by the tool changes how memory looks in the debugger. 

### Production Builds

Generally, **do not use full sanitizers in production**. The 2x–15x performance hit and 2x–4x memory increase are usually deal-breakers. However, there are two exceptions:

1.  **Hardened UBSan:** You can enable specific, low-overhead UBSan checks (e.g., `-fsanitize=signed-integer-overflow -fno-sanitize-recover`) to force a clean crash instead of allowing a security vulnerability to be exploited.
2.  **GWP-ASan:** A "sampling" version of ASan designed for production. It only instruments a small fraction of allocations (e.g., 1%), keeping overhead under 1% while still catching rare memory errors in the wild.

---

## Advanced: Control Flow Integrity (CFI)

For security-critical applications, Clang offers **CFI** (`-fsanitize=cfi`), which is often used in production (e.g., in Android and Chrome).

* **Purpose:** Prevents attackers from hijacking the program's control flow (like ROP attacks).
* **Mechanism:** It ensures that indirect function calls and virtual method calls only target valid, type-compatible destinations.
* **Requirement:** Requires Link Time Optimization (**LTO**) to be enabled (`-flto`).

---

## Build and Test

```bash
# Configure using the Sanitize preset
cmake --preset Sanitize

# Build the project
cmake --build --preset Sanitize
```

### CTest

```bash
# Run tests using the Test Preset (injects environment variables)
ctest --preset Sanitize -V

# Filter tests (regex)
ctest --preset Sanitize -R "UseAfterFree" -V
```

### GoogleTest

Runtime filter:
```bash
# manually set runtime options for sanitizers
export ASAN_OPTIONS="halt_on_error=1:detect_leaks=1"
export UBSAN_OPTIONS="print_stacktrace=1:halt_on_error=1"

# Run tests
./build/Sanitize/tests/unit_tests --gtest_filter=AddressSanitizer.*
./build/Sanitize/tests/unit_tests --gtest_filter=AddressSanitizer.UseAfterFree
```

---

## HarmonyOS Integration

### Runtime Library Deployment

HarmonyOS may not include the specific `ASan`/`UBSan` runtime libraries matching the SDK version.

When you link against `-fsanitize=address`, the binary depends on `libclang_rt.asan-*.so`.
Find this `.so` in your SDK toolchain and manually push it to the device (typically `/data/local/tmp/` or your app's native library path) using `hdc file send`.

Ensure the loader can find the runtime libraries at runtime:

```bash
hdc shell

export LD_LIBRARY_PATH=/data/local/tmp
/data/local/tmp/<executable>
```

```bash
hdc shell "ASAN_OPTIONS=halt_on_error=1:log_path=/data/local/tmp/asan.log /data/local/tmp/<executable>"
```

> Note: writing to **stderr** can sometimes be swallowed by the system logs. Using `log_path` ensures you actually get the report.

### GWP-ASan

HarmonyOS often runs on resource-constrained hardware, running a full `ASan` build is not feasible. 

Clang 15+ supports **GWP-ASan**. It uses a **guard-page based approach** to sample a small percentage of allocations.

It has near-zero CPU overhead and negligible memory impact. It is typically enabled via env variables in the system allocator rather than a separate compiler flag. Check if your HarmonyOS SDK version supports `GWP_ASAN_OPTIONS`.

### HWASan (Hardware-Assisted ASan)

If you are targeting `aarch64` (ARMv8.5+ with Memory Tagging Extension), consider `HWASan` (`-fsanitize=hwaddress`).

It uses **"pointer tagging"** rather than shadow memory **"redzones"**. 
It uses significantly less memory (usually ~10-35% overhead vs ASan) and is much faster on mobile chipsets.

Requires specific kernel support, which is common in modern HarmonyOS/Android-based kernels.


### Cross-Compilation Quirks

The `llvm-symbolizer` must reside on your host machine, not the device. 

To get a **readable trace**, pull the logs from the device and run them through the host-side symbolizer:

```bash
hdc shell "cat /data/local/tmp/asan.log" | llvm-symbolizer --obj /path/to/local/binary_with_symbols
```
