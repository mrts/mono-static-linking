const char* hello()
{
    static const char* hello_string = "hello from C";
    return hello_string;
}
