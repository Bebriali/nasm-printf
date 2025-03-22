#include <stdio.h>

extern "C" int cdecl myprintf(const char* format, ...);

int main()
{
    myprintf
    (
        "printing such strings in that particular way is so '%x' and, to be %s, ill do it %d years", 
        0xdead, 
        "honest", 
        1000000
    );
    
    myprintf
    (
        "%s%o%%%%%%x%d%string%ceal&stroke",
        "string", 
        888, 
        0xface,
        1000
    );

    return 0;
}