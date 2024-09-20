volatile char *const out = (volatile char *const)0x80000000;

void print_str(char *str) {
	while(*str) *out = *str++;
}

void print4digits(unsigned digits) {
	unsigned x=1000;
	for (int i = 0; i < 4; ++i) {
		unsigned digit = digits/x;
		digits -= digit*x;
		*out = digit + '0';
		x /= 10;
	}
	*out = '\n';
}

// Dik T. Winter "Computing Pi in C"
// https://crypto.stanford.edu/pbc/notes/pi/code.html
void main() {
	// for (;;) { 
	// 	print_str("hello world!\n");
	// }
	print_str("800 digits of Pi:\n");
	int r[2800 + 1];
	int i, k;
	int b, d;
	int c = 0;
	for (i = 0; i < 2800; i++) {
		r[i] = 2000;
	}
	r[i] = 0;
	for (k = 2800; k > 0; k -= 14) {
		d = 0;
		i = k;
		for (;;) {
			d += r[i] * 10000;
			b = 2 * i - 1;
			r[i] = d % b;
			d /= b;
			i--;
			if (i == 0) break;
			d *= i;
		}
		print4digits(c + d / 10000);
 		c = d % 10000;
	}

}