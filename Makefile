TARGET = printf
CC = g++
CFLAGS =  -Wall -Wextra -Weffc++ -Wcast-align -Wcast-qual -Wconversion -Wctor-dtor-privacy -Wempty-body 			\
		  -Wfloat-equal -Wformat-security -Wformat=2 -Wignored-qualifiers -Winit-self -Winline -Wlogical-op 		\
		  -Wmain -Wmissing-declarations -Wno-missing-field-initializers -Wmissing-include-dirs -Wnon-virtual-dtor 	\
		  -Woverloaded-virtual -Wpointer-arith -Wredundant-decls -Wshadow -Wsign-promo -Wstack-usage=8192 			\
		  -Wstrict-aliasing -Wstrict-null-sentinel -Wswitch-default -Wswitch-enum -Wtype-limits -Wundef 			\
		  -Wunreachable-code -Wwrite-strings -fexceptions -g -pipe -D_DEBUG -D_EJUDGE_CLIENT_SIDE -D_EJC

PREF_SRC_C = ./src_c/
PREF_SRC_S = ./src_s/
PREF_OBJ   = ./obj/

SRC_C = $(wildcard $(PREF_SRC_C)*.cpp)
SRC_S = $(wildcard $(PREF_SRC_S)*.s)
OBJ_C = $(patsubst $(PREF_SRC_C)%.cpp, $(PREF_OBJ)%.o, $(SRC_C))
OBJ_S = $(patsubst $(PREF_SRC_S)%.s,   $(PREF_OBJ)%.o, $(SRC_S))

$(TARGET) : $(OBJ_C) $(OBJ_S)
	$(CC) $(OBJ_C) $(OBJ_S) -o $(TARGET) -no-pie

$(PREF_OBJ)%.o : $(PREF_SRC_C)%.cpp
	$(CC) -c $< -I include -o $@ $(CFLAGS)

./src_s/main.o : ./src_s/main.s
	nasm -f elf64 -o ./obj/main.o ./src_s/main.s

./src_s/myprintf.o : ./src_s/myprintf.s
	nasm -f elf64 -o ./obj/myprintf.o ./src_s/myprintf.s

clean :
	rm $(TARGET).exe $(PREF_OBJ)*.o
