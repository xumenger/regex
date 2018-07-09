#include "regex.h"

#include <iostream>

using namespace std;

int main()
{
    cout << "false = " << false << endl;
    cout << "true  = " << true << endl;
    cout << match("aaa", "a.a") << " = " << true << endl;
    cout << match("aaa", "ab*ac*a") << " = " << true << endl;
    cout << match("aaa", "aa.a") << " = " << false << endl;
    cout << match("aaa", "ab*.a") << " = " << true << endl;
    cout << match("aaa", "ab*a") << " = " << false << endl;

    return 0;
}
