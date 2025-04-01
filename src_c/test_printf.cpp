#include <stdio.h>

extern "C" int _start_printf(const char* format, ...);
extern "C" void c_exit(void);

int main()
{
    printf("main functino started!\n");

    _start_printf
    (
        "%%check if percent\nxmm..\n"
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

    printf("mandelbro%cher\n", 't');

    _start_printf
    (
        "%s%o%%%%%x%d%%string%%ceal//&stroke\n",
        "string",
        888,
        0xface,
        1000
    );

    _start_printf
    (
        "check%dng more %% arguments%c How about %d %c? it's strange if it would %x problems, isn't it? %o and %b",
        1,
        '.',
        7,
        '?',
        0xface,
        88,
        0b1001001
    );

    printf("main function finished!\n");

    c_exit();
}
