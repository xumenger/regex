#include "regex.h"
#include <iostream>
#include <stack>

using namespace std;

bool match(const char *string, const char *pattern)
{
    stack<char> S;

    if(NULL == string || NULL == pattern)
        return false;

    char before = '\0';
    while(true){
        if('\0' == *string && '\0' == *pattern && S.size() == 0)
            return true;
        if('\0' != *string && '\0' == *pattern && S.size() == 0)
            return false;
        if('\0' != *pattern && '\0' == *string)
            return false;

        if(S.size() == 2){
            char second = S.top();
            S.pop();
            char first = S.top();
            S.pop();
            if(first == *string || (('.' == first) && (*string == before))){
                before = '\0';
                string++;
                S.push(first);
                S.push(second);
            }
        }
        else if('*' == *(pattern + 1)){
           if(*pattern == *string || '.' == *pattern){
               if('.' == *pattern)
                   before = *string;
               string ++;
               S.push(*pattern);
               S.push(*(pattern + 1));
               pattern += 2;
           }
           else{
               pattern += 2;
           }
        }
        else if(*string == *pattern || '.' == *pattern){
            string ++;
            pattern ++;
        }
    }
}

