all: dzielenie

dzielenie: dzielenie.o
	ld -m elf_i386 -o dzielenie dzielenie.o

dzielenie.o: dzielenie.s
	as --32 --gstabs -o dzielenie.o dzielenie.s
