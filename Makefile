ASM=nasm
ASFLAGS=-f elf64 -g -F dwarf -I include/
LDFLAGS=-e _start -I/lib/my/libasm.so -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc 
SOURCES=src/main_shell.asm src/fork_exec.asm src/create_arg_exec.asm src/str_to_tab.asm src/change_directory.asm src/builtin_cd.asm
OBJECTS=$(SOURCES:.asm=.o)
EXECUTABLE=asmsh

all: my_lib $(SOURCES) $(EXECUTABLE)
                 
$(EXECUTABLE): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

my_lib:
	make -C lib/my

%.o: %.asm
	$(ASM) $(ASFLAGS) $< -o $@

fclean:
	rm -f $(EXECUTABLE) lib/my/libasm.so
	rm -f src/*.o lib/my/*.o

re:	fclean all
