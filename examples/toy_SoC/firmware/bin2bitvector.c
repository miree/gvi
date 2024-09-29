#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

uint32_t swap_bytes(uint32_t x)
{
	uint32_t result  = (x>>24);
	         result |= (x<<24);
	         result |= (x&0x00ff0000)>>8;
	         result |= (x&0x0000ff00)<<8;
	return result;
}

int main(int argc, char *argv[]) {
	// put any argument (i.e. --change-endianess) to enable endianess conversion
	int change_endianess = (argc==2); 
	// read from stdin (file descriptor 0)
	// write to stdout (file descriptor 1)
	int fd_in = 0;
	int fd_out = 1;

	uint32_t word;
	while(1) {
		if (read(fd_in, &word, sizeof(word)) != sizeof(word)) return 0;
		if (change_endianess) word = swap_bytes(word);
		for (int i = 0; i < 32; ++i) {
			char bit = (word&0x80000000)?'1':'0';
			if (write(fd_out, &bit, 1) != 1) return 1;
			word <<= 1;
		}
		char newline = '\n';
		if (write(fd_out, &newline, 1) != 1) return 1;
	}
	return 1;
}