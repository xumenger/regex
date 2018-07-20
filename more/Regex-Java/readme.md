copy from [https://github.com/earayu/Regex](https://github.com/earayu/Regex)

## 简介

实现了正则表达式的连接、或、闭包操作，可以使用括号和转义元符号：`. | * ( ) \`

主方法在TEST.java

步骤：

* 处理转义符号，然后把正则表达式转换成逆波兰式
* 将表达式转换成NFA
* 将表达式转换成DFA
* 模拟DFA运行

## 编译运行

编译

```
cd Regex/lexical/
javac *.java
```

运行

```
cd ..
java lexical.TEST
```

参考[使用java命令运行class文件提示“错误：找不到或无法加载主类“的问题分析](http://www.cnblogs.com/wangxiaoha/p/6293340.html)，处理lexical是因为有package的问题

