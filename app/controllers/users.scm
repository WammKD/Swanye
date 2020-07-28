;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(define-syntax if-let-helper
  (syntax-rules ()
    [(_ letVersion
        ([bnd             val]    ...)
        (cnd                      ...)
        ()                             then else) (letVersion ([bnd val] ...)
                                                    (if (and cnd ...) then else))]
    [(_ letVersion
        ([bnd             val]    ...)
        (cnd                      ...)
        ([binding       value] . rest) then else) (if-let-helper letVersion
                                                                 ([bnd val] ... [binding value])
                                                                 (cnd       ...           value)
                                                                 rest                            then else)]
    [(_ letVersion
        ([bnd             val]    ...)
        (cnd                      ...)
        ([binding funct value] . rest) then else) (if-let-helper letVersion
                                                                 ([bnd val] ... [binding value])
                                                                 (cnd       ... (funct binding))
                                                                 rest                            then else)]))
(define-syntax if-let
  (syntax-rules ()
    [(_ ([binding         value]  ...) then else) (let ([binding value] ...)
                                                    (if (and binding ...) then else))]
    [(_ (binding-funct-value      ...) then else) (if-let-helper let
                                                                 ()
                                                                 ()
                                                                 (binding-funct-value ...) then else)]))
(define-syntax if-let*
  (syntax-rules ()
    [(_ ([binding         value]  ...) then else) (let* ([binding value] ...)
                                                    (if (and binding ...) then else))]
    [(_ (binding-funct-value      ...) then else) (if-let-helper let*
                                                                 ()
                                                                 ()
                                                                 (binding-funct-value ...) then else)]))

(define-syntax process-user-account-as
  (syntax-rules ()
    [(_ userVar (rcVar) then)
          (let ([poss ($PEOPLE
                        'get
                        #:columns   '(*)
                        #:condition (where #:USERNAME (params rcVar "user")))])
            (if (null? poss)
                (redirect-to rcVar "/404")
              (let ([userVar (car poss)])
                then)))]))
