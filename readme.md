# Regex

语法：

```
concatenation: abc     match "abc"
alternation: abc|def   match "abc" or "def"
closure: a*            match "" or "a" or "aa" or "aaa" or "aaa..."
```

BNF表示

```
re                 ::= alter
re_base            ::= char | char_range | '(' re ')'
alter              ::= alter_base alter_end
alter_base         ::= concat
alter_end          ::= '|' alter_base alter_end | epsilon
concat             ::= concat_base concat_end
concat_base        ::= re_base | closure
concat_end         ::= concat_base concat_end | epsilon
closure            ::= re_base '*'
```
