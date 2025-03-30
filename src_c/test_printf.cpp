#include <stdio.h>

extern "C" int _start_printf(const char* format, ...);
extern "C" void c_exit(void);

int main()
{
    printf("main functino started!\n");

    _start_printf
    (
        "%%check if percent\nlox\n"
    );

    printf("\nintermediate printf\n");

    _start_printf
    (
        "go \n\n"
    );

    _start_printf
    (
        "print just one char: %c \n",
        'x'
    );
    
    _start_printf
    (
        "print just one string: %s \n",
        "sosi lox love u)))\n"
    );
    
    _start_printf
    (
       "printing such strings in that particular way is so '%d' and, to be %x, ill do it %s years\n\0",
       1000000,
       0xdead,
       "honest"
    );

    printf("loshara ebucha%ca\n", 'y');

    _start_printf
    (
        "%s%o%%%%%x%d%%string%%ceal//&stroke\n",
        "string",
        888,
        0xface,
        1000
    );

    printf("main function finished!\n");

    c_exit();
}
