#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>

const char* message()
{
    static const char* msg = "dlopen self works";
    return msg;
}

void die(const char* msg)
{
    fprintf(stderr, "%s\n", msg);
    exit(1);
}

int main()
{
    void *self = dlopen(0, RTLD_GLOBAL | RTLD_LAZY);
    const char* (*message_fn_ptr)();

    if (!self)
        die(dlerror());

    message_fn_ptr = dlsym(self, "message");
    if (!message_fn_ptr)
        die(dlerror());

    dlclose(self);

    printf("%s\n", message_fn_ptr());

    return 0;
}
