NASM 		=	nasm
LD  		=	ld
RM		=	rm -f

NASMFLAGS 	+=	-f elf64 -Ox

LDFLAGS 	+=	-shared

NAME 		=	libasm.so

SRC 		=	strlen.asm 	\
			strchr.asm 	\
			strcmp.asm 	\
			strncmp.asm 	\
			rindex.asm 	\
			strstr.asm   	\
			strpbrk.asm 	\
			strcspn.asm 	\
			strcasecmp.asm	\
			memmove.asm	\
			memset.asm	\
			write_str.asm	\

OBJ  		=	$(SRC:.asm=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

clean:
	$(RM) $(OBJ)

fclean: clean
	$(RM) $(NAME)

re: fclean all

%.o: %.asm
	$(NASM) $< $(NASMFLAGS)

.PHONY: all clean fclean re
