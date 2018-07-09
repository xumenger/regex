#include "regex.h"
#include <iostream>

bool matchCore(const char *str, const char *pattern)
{

}

bool match(const char *str, const char *pattern)
{
    if(NULL == str || NULL == pattern)
        return false;
    return matchCore(str, pattern);
}

