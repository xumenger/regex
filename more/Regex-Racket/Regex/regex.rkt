#lang racket

; <pat> ::= <string>
;         | (<pat> *)
;         | (<pat> +)
;         | (<pat> ?)
;         | (<pat> or <pat>)

; reg-match : (listof pat) string integer -> boolean
(define (reg-match pats str pos)
  (if (null? pats) (= pos (string-length str))
      (match (car pats)
        [(? string?) (let ([len (string-length (car pats))])
                       (and (>= (string-length str) (+ pos len))
                            (substring=? (car pats) str pos (+ pos len))
                            (reg-match (cdr pats) str (+ pos len))))]
        [`(,p1 or ,p2) (or (reg-match `(,p1 ,@(cdr pats)) str pos)
                          (reg-match `(,p2 ,@(cdr pats)) str pos))]
        [`(,p *) (or (reg-match (cdr pats) str pos)
                     (reg-match `(,p ,@pats) str pos))]
        [`(,p +) (reg-match `(,p (,p *) ,@(cdr pats)) str pos)]
        [`(,p ?) (reg-match `((,p or "") ,@(cdr pats)) str pos)]
        [else (error "bad pattern")])))

; auxiliary function
(define (substring=? pat str start end)
  (for/and ([i (in-range start end)]
            [j (in-naturals)])
    (char=? (string-ref pat j) (string-ref str i))))

; test
(reg-match '("a" ("b"*) (("c"?) or ("d"+))) "abbc" 0)
(reg-match '(("a"*)) "aaaaaaaaa" 0)
(reg-match '("a" ("b"*)) "abbbb" 0)