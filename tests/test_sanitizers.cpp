#include <gtest/gtest.h>

#include <climits>

TEST(AddressSanitizer, HeapBufferOverflow) {
	int* array = new int[10];
	array[10] = 1; // ASan detects: heap-buffer-overflow
	delete[] array;
}

TEST(AddressSanitizer, UseAfterFree) {
	int* p = new int(42);
	delete p;
	int value = *p; // ASan detects: use-after-free
	(void)value;
}

TEST(AddressSanitizer, StackBufferOverflow) {
	int stack_array[5];
	stack_array[5] = 10; // ASan detects: stack-buffer-overflow
}

TEST(UndefinedBehavior, IntegerOverflow) {
	int x = INT_MAX;
	x += 1; // UBSan detects: signed integer overflow
	(void)x;
}

TEST(UndefinedBehavior, NullPointerDereference) {
	int* p = nullptr;
	// We use a volatile pointer to prevent the compiler from optimizing this out
	volatile int* vp = p;
	int x = *vp; // UBSan detects: load of null pointer
	(void)x;
}

TEST(UndefinedBehavior, ShiftExponentTooLarge) {
	int x = 1 << 32; // UBSan detects: shift exponent 32 is too large for 32-bit type
	(void)x;
}