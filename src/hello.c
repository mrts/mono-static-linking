#include <wchar.h>

const wchar_t* hello()
{
    static const wchar_t* hello_string = L"hello from C";
    return hello_string;
}
