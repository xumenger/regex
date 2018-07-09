#include "regex.h"

#include <iostream>

using namespace std;

int main()
{
    cout << "false = " << false << endl;
    cout << "true  = " << true << endl;
    cout << match("aaa", "a.a") << endl;
    cout << match("aaa", "ab*ac*a") << endl;
    cout << match("aaa", "aa.a") << endl;
    cout << match("aaa", "ab*.a") << endl;
    cout << match("aaa", "ab*a") << endl;

    return 0;
}
