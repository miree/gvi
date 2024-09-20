all: firmware.bitvector


CC=riscv64-elf-gcc \
  -mabi=ilp32 -march=rv32im \
  -nostartfiles \
  -mdiv \
  -nostdlib -nodefaultlibs -ffreestanding \
  -Wl,--no-relax \
  -Wall

firmware.bitvector: firmware.bin bin2bitvector
	./bin2bitvector < $< > $@

bin2bitvector: bin2bitvector.c
	gcc -Wall -o $@ $<

firmware.bin: firmware
	riscv64-elf-objcopy -O binary firmware firmware.bin

firmware: crt0.S firmware.c
	$(CC) -Wl,-Map=firmware.map -Wl,-T,riscv32.ld -O4 -o firmware crt0.S firmware.c

firmware.s: firmware.c
	$(CC) -S firmware.c

clean:
	rm -rf *.map *.o *.bin *.bitvector bin2bitvector firmware 
