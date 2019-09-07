#lang plai-typed

(define-type ArithC
  [numC (n : number)]
  [plusC (l : ArithC) (r : ArithC)]
  [multC (l : ArithC) (r : ArithC)]
  [divC (l : ArithC) (r : ArithC)]
  [ifC (condition : ArithC) (true : ArithC) (false : ArithC)]
  [idC (s : symbol)]
  [appC (fun : symbol) (arg : ArithC)]
  )

(define-type ArithS
  [numS    (n : number)]
  [plusS   (l : ArithS) (r : ArithS)]
  [bminusS (l : ArithS) (r : ArithS)]
  [uminusS (e : ArithS)]
  [multS   (l : ArithS) (r : ArithS)]
  [divS   (l : ArithS) (r : ArithS)]
  [ifS (c : ArithS) (t : ArithS) (f : ArithS)]
  [idS (s : symbol)]
  [appS (fun : symbol) (arg : ArithS)]
  )

(define-type FunDefC
  [fdC (name : symbol) (arg : symbol) (body : ArithC)]
  )

(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS    (n)   (numC n)]
    [plusS   (l r) (plusC (desugar l) (desugar r))]
    [multS   (l r) (multC (desugar l) (desugar r))]
    [divS   (l r) (divC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]
    [uminusS (e)   (multC (numC -1) (desugar e))]
    [ifS (c t f) (ifC (desugar c) (desugar t) (desugar f))]
    [idS (s) (idC s)]
    [appS (fun arg) (appC fun (desugar arg))]
    ))

(define (subst [value : ArithC] [id : symbol] [expr : ArithC]) : ArithC
  (type-case ArithC expr
    [numC (n) expr]
    [idC (s) (cond
                [(symbol=? s id) value]
                [else expr])]
    [appC  (f a) (appC f (subst value id a))]
    [plusC (l r) (plusC (subst value id l) (subst value id r))]
    [multC (l r) (multC (subst value id l) (subst value id r))]
    [divC (l r) (divC (subst value id l) (subst value id r))]
    [ifC (c s n) (ifC   (subst value id c)
                        (subst value id s) (subst value id n))]
  ))

(define (interp [a : ArithC] [fds : (listof FunDefC)]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l fds) (interp r fds))]
    [multC (l r) (* (interp l fds) (interp r fds))]
    [divC (l r) (/ (interp l fds) (interp r fds))]
    [ifC (c t f) (cond [(zero? (interp c fds)) (interp f fds)] [else (interp t fds)])]
    [idC (_) (error 'interp "it shouldn't be found!")]
    [appC (fun arg) (local ([define fd (get-fundef fun fds)])
                      (interp (subst arg (fdC-arg fd) (fdC-body fd)) fds))]
    ))

(define (parse [s : s-expression]) : ArithS
  (cond
    [(s-exp-number? s) (numS (s-exp->number s))]
    [(s-exp-list? s)
     (let ([sl (s-exp->list s)])
       (case (s-exp->symbol (first sl))
         [(+) (plusS (parse (second sl)) (parse (third sl)))]
         [(*) (multS (parse (second sl)) (parse (third sl)))]
         [(/) (divS (parse (second sl)) (parse (third sl)))]
         [(-) (bminusS (parse (second sl)) (parse (third sl)))]
         [(~) (uminusS (parse (second sl)))]
         [(if) (ifS (parse (second sl)) (parse (third sl)) (parse (fourth sl)))]
         [(call) (appS (s-exp->symbol (second sl)) (parse (third sl)))]
         [else (error 'parse "invalid list input")]))]
    [else (error 'parse "invalid input")]))

(define (get-fundef [n : symbol] [fds : (listof FunDefC)]) : FunDefC
  (cond
    [(empty? fds) (error 'get-fundef "reference to a not defined function")]
    [(cons? fds) (cond
                    [(equal? n (fdC-name (first fds))) (first fds)]
                    [else (get-fundef n (rest fds))]
                    )]))

(define library (list
                    [fdC 'twice 'x (plusC (idC 'x) (idC 'x))]
                    [fdC 'squared 'y (multC (idC 'y) (idC 'y))]
                    [fdC 'factorial 'n (ifC  (idC 'n)
                        (multC (appC 'factorial (plusC (idC 'n) (numC -1)))
                          (idC 'n))
                        (numC 1))]
                    ))

(interp (desugar (parse (read))) library)
