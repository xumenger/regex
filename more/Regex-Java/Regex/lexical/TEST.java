package lexical;

import java.util.Scanner;
import lexical.RE.*;

public class TEST{
    // (a|b)(c|e) (a|b)*(c|e)
    @SuppressWarnings("resource")
    public static void main(String[] args){
        // (d(a|b)*c)|a
        RE re = new RE("(ab)*|(cd)*");
        // 匹配正则表达式
        while(true){
            System.out.println("RE: " + re.getRE());

            // 检查输入的字符串是否符合正则表达式
            System.out.println(re.match(new Scanner(System.in).nextLine()));
        }
    }
}
