#include "regex.h"

#include <iostream>

using namespace std;

int main()
{
    cout << "false = " << false << endl;
    cout << "true  = " << true << endl;

    cout << match("aaaaa", ".*aaaa") << " = " << true << endl;

    cout << match("aab", ".*") << " = " << false << endl;
    cout << match("ab", ".*") << " = " << false << endl;
    cout << match("aa", "a*") << " = " << true << endl;

    cout << match("aaa", "aa.a") << " = " << false << endl;
    cout << match("aaa", "ab*ac*a") << " = " << true << endl;
    cout << match("aaa", "a.a") << " = " << true << endl;
    cout << match("aaa", "ab*.a") << " = " << true << endl;
    cout << match("aaa", "ab*a") << " = " << false << endl;
    cout << match("abc", "a.c") << " = " << true << endl;

    cout << match("abcdef", "a.*c.*") << " = " << false << endl;
    cout << match("mississippi", "mis*is*p*.") << " = " << false << endl;

    return 0;
}
