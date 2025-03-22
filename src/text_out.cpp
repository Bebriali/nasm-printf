#include <stdio.h>
#include <stdlib.h>

const int BUF_SIZE = 100;

enum ERRORS
{
    SUCCESS  =  0,
    NULL_PTR = -1
};

struct str_mark
{
    char** str_ptrs;
    size_t str_cntr;
    
    char** eos_ptrs;
    size_t eos_cntr;

    argument* arr_args;

    size_t ptrs_q;
};

union prntf_arg
{
    int integer;
    char literal;
    char* string;
};

struct argument
{
    char type;
    prntf_arg arg;
};

int TestPrintf(const char* filename);
str_mark* CutByNul(char** str, size_t str_size);
str_mark* MarkCtor(void);
argument** GetArgs(str_mark* mark);
extern "C" int myprintf(char* format, ...);

int main()
{
    return TestPrintf("test_file.txt");
}

int TestPrintf(const char* filename)
{
    FILE* test = fopen(filename, "rb");

    char* Buffer = (char*) calloc(BUF_SIZE, sizeof(char));
    if (!Buffer)
    {
        Buffer = NULL;
        return NULL_PTR;
    }

    fread(Buffer, sizeof(char), BUF_SIZE, test);

    str_mark* test_mark = CutByNul(&Buffer, BUF_SIZE);
    if (test_mark == NULL)
    {
        return NULL_PTR;
    }

    for (size_t i = 0; i < test_mark->ptrs_q; i++)
    {
        char* test_i = NULL;
        sprintf(test_i, "%s", test_mark->str_ptrs[i]);
        myprintf(test_i, ...);
    }

    return SUCCESS;
}

str_mark* MarkCtor(void)
{
    str_mark* mark = (str_mark*) calloc(1, sizeof(str_mark));
    if (mark == NULL)
    {
        return NULL;
    }

    mark->str_ptrs = (char**) calloc(mark->ptrs_q, sizeof(char*));
    if (mark->str_ptrs == NULL)
    {
        return NULL;
    }
    mark->eos_ptrs = (char**) calloc(mark->ptrs_q, sizeof(char*));
    if (mark->eos_ptrs == NULL)
    {
        return NULL;
    }

    mark->arr_args = (argument*) calloc(1, sizeof(argument));
    if (mark->arr_args == NULL)
    {
        return NULL;
    }

    mark->str_cntr = 0;
    mark->eos_cntr = 0;
    mark->ptrs_q   = 0;

    return mark;
}

argument** GetArgs(str_mark *mark)
{

    return nullptr;
}

str_mark* CutByNul(char** str, size_t str_size)
{
    str_mark* test = MarkCtor();

    test->ptrs_q = str_size;
    test->str_ptrs[test->str_cntr++] = *str;

    for (size_t i = 0; i < str_size; i++)
    {
        if (*str[i] == '\n')
        {
            //*str[i] = '\0';
            test->str_ptrs[test->str_cntr++] = str[i + 1];

            if (test->str_cntr > test->ptrs_q)
            {
                test->ptrs_q *= 2;
                void* t = realloc(test->str_ptrs, test->ptrs_q * sizeof(char**));
                if (t == NULL)
                {
                    return NULL;
                }
                test->str_ptrs = (char**) t;
            }
        }

        if (*str[i] == '$')
        {
            *str[i] = '\0';
            test->eos_ptrs[test->eos_cntr++] = str[i + 1];

            if (test->str_cntr > test->ptrs_q)
            {
                test->ptrs_q *= 2;
                void* t = realloc(test->eos_ptrs, test->ptrs_q * sizeof(char**));
                if (t == NULL)
                {
                    return NULL;
                }
                test->eos_ptrs = (char**) t;
            }
        }
    }

    return test;
}
