#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>  // Added: for PRIu32, PRIu64, SCNu32
#include <assert.h>
#include <stdbool.h>

bool add_uint64(uint64_t a, uint64_t b, uint64_t *result) {
    if (a > UINT64_MAX - b) {
        return false;  // Overflow would occur
    }
    *result = a + b;
    return true;
}

uint64_t compute_fibonacci(uint32_t n) {
    assert(n <= 93);  // F(93) is max that fits in uint64_t

    if (n == 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }

    uint64_t prev = 0;
    uint64_t curr = 1;
    uint32_t i = 2;

    while (i <= n) {
        uint64_t next;
        if (!add_uint64(prev, curr, &next)) {
            assert(false);
            return 0;
        }
        prev = curr;
        curr = next;
        ++i;

        assert(i <= n + 1);  // Provable loop bound
    }

    return curr;
}

int main(void) {
    uint32_t n;

    printf("Enter a non-negative integer n to compute the nth Fibonacci number (0-93 recommended): ");
    if (scanf("%" SCNu32, &n) != 1) {  // Fixed format string
        printf("Invalid input. Exiting.\n");
        return 1;
    }

    if (n > 93) {
        printf("n too large: overflow in uint64_t beyond 93. Exiting.\n");
        return 1;
    }

    uint64_t fib = compute_fibonacci(n);  // Moved here to avoid unused warning
    printf("Fibonacci(%" PRIu32 ") = %" PRIu64 "\n", n, fib);  // Fixed format strings

    return 0;
}