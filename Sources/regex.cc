#include "regex.h"
#include <iostream>

bool matchCore(const char *str, const char *pattern)
{
    if('\0' == *str && '\0' == *pattern)
        return true;
    if('\0' != *str && '\0' == *pattern)
        return false;

    if('*' == *(pattern + 1)){
        if(*pattern == *str || *pattern == '.')
            return matchCore(str + 1, pattern) || matchCore(str + 1, pattern + 2);
        else
            return matchCore(str, pattern + 2);
    }
    else if(*str == *pattern || *pattern == '.')
        return matchCore(str + 1, pattern + 1);

    return false;
}

bool match(const char *str, const char *pattern)
{
    if(NULL == str || NULL == pattern)
        return false;
    return matchCore(str, pattern);
}

