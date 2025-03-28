#include <stdio.h>

extern "C" int _start_printf(const char* format, ...);

int main()
{
    printf("main functino started!\n");

    _start_printf
    (
        "printing such strings in that particular way is so '%x' and, to be %s, ill do it %d years\n",
        0xdead,
        "honest",
        1000000
    );

    printf("loshara ebucha%ca\n", 'y');

    _start_printf
    (
        "%s%o%%%%%%x%d%string%ceal&stroke\n",
        "string",
        888,
        0xface,
        1000
    );

    printf("main function finished!\n");

    return 0;
}
