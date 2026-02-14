# What is Hardening?

**Hardening** is a set of "always-on" compiler and linker flags used in production to mitigate exploits (like buffer overflows or ROP attacks). 

Unlike sanitizers, they are designed for **minimal overhead**. In Clang, you integrate this by using a combination of stack protection, memory layout randomization (PIE), and standard library assertions.

## Hardening Integration

For HarmonyOS or any modern C++ target, use these flags in your Release builds to ensure a high security baseline.

### Stack Protection

Prevents stack-smashing attacks by inserting "canaries" that are checked before a function returns.

```bash
-fstack-protector-strong
```

### Fortify Source

Replaces unsafe standard C functions (`memcpy`, `strcpy`, etc.) with safer, bounds-checked versions where the size is known at compile time.

```bash
-D_FORTIFY_SOURCE=3
```

> **Note:** Clang 15+ supports Level 3, which uses `__builtin_dynamic_object_size` to catch more overflows than Level 2.

### Position Independent Executables (PIE)

Required for **ASLR** (Address Space Layout Randomization). This makes it harder for an attacker to predict where your code is in memory.

```bash
-fPIE -pie
```

### Read-Only Relocations

Hardens the binary's data sections so that function pointers (like the Global Offset Table) cannot be overwritten after the program starts.

```bash
-Wl,-z,relro -Wl,-z,now
```

### Standard Library Hardening

Specifically for `libc++`, you can enable internal assertions that catch iterator invalidation and out-of-bounds access in production.

```bash
-D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST
```

> Modes: `FAST` (low overhead for production), `EXTENSIVE` (more checks), and `DEBUG` (full checks)

### CMake Integration (Example)

```cmake
if(ENABLE_HARDENING)
  target_compile_definitions(${PROJECT_NAME} PRIVATE _FORTIFY_SOURCE=3)
  target_compile_definitions(${PROJECT_NAME} PRIVATE _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_FAST)
  
  target_compile_options(${PROJECT_NAME} PRIVATE 
    -fstack-protector-strong 
    -fPIE
  )
  
  target_link_options(${PROJECT_NAME} PRIVATE 
    -pie 
    -Wl,-z,relro -Wl,-z,now
  )
endif()
```

### HarmonyOS Considerations

For Clang on ARM64 (HarmonyOS), you should consider **Branch Protection**. 

This uses the hardware's **Pointer Authentication** (PAC) and **Branch Target Identification** (BTI) to prevent ROP/JOP attacks.

```bash
-mbranch-protection=standard
```

`standard`: enables both PAC (signing return addresses) and BTI (ensuring jumps only land on valid targets). This is a "must-have" for modern ARM security.

#### Standard Library Hardening

The hardening modes were formally introduced in LLVM 18, but the groundwork exists in Clang 15. 

In Clang 15, you don't have the single `_LIBCPP_HARDENING_MODE` macro yet; instead, you use assertions.

Use `-D_LIBCPP_ENABLE_ASSERTIONS=1` to enable basic bounds checking for `std::vector`, `std::string`, etc.

HarmonyOS's version of **musl** (1.2.x+) uses the `mallocng` allocator. It has built-in hardening against heap metadata corruption and use-after-free, which works "out of the box" without extra flags.

