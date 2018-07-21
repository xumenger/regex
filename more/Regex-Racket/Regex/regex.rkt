#lang racket

; <pat> ::= <string>
;         | (<pat> *)
;         | (<pat> +)
;         | (<pat> ?)
;         | (<pat> or <pat>)

; reg-match : (listof pat) string integer -> boolean
(define (reg-match pats str pos)
  ; 判断模式列表是否为空
  (if (null? pats) (= pos (string-length str))
      ; car 用于获取列表的第一个元素
      ; match 用于分别和下面的各种格式进行匹配
      (match (car pats)
        ; 第一个元素是不是纯字符串，比如 ("ab")
        [(? string?) (let ([len (string-length (car pats))])
                       (and (>= (string-length str) (+ pos len))
                            (substring=? (car pats) str pos (+ pos len))
                            (reg-match (cdr pats) str (+ pos len))))]
        ; 第一个元素是不是 pat1 or pat2 的格式，比如 (("c"?) or ("d"+))
        ; cdr 用于获取列表除了第一个元素以外的所有元素
        [`(,p1 or ,p2) (or (reg-match `(,p1 ,@(cdr pats)) str pos)
                          (reg-match `(,p2 ,@(cdr pats)) str pos))]
        ; 第一个元素是不是 pat* 的格式，比如 ("b"*)
        [`(,p *) (or (reg-match (cdr pats) str pos)
                     (reg-match `(,p ,@pats) str pos))]
        ; 第一个元素是不是 pat+ 的格式，比如 ("c"+)
        [`(,p +) (reg-match `(,p (,p *) ,@(cdr pats)) str pos)]
        ; 第一个元素是不是 pat? 的格式，比如 ("c"?)
        [`(,p ?) (reg-match `((,p or "") ,@(cdr pats)) str pos)]
        ; 其他不支持的正则语法
        [else (error "bad pattern")])))

; auxiliary function
(define (substring=? pat str start end)
  (for/and ([i (in-range start end)]
            [j (in-naturals)])
    (char=? (string-ref pat j) (string-ref str i))))

; test
(reg-match '("ab") "ab" 0)
(reg-match '("a" ("b"*) (("c"?) or ("d"+))) "abbc" 0)
(reg-match '(("a"*)) "aaaaaaaaa" 0)
(reg-match '("a" ("b"*)) "abbbb" 0)