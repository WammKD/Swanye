;; Controller auth definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models PEOPLE)
             ((artanis utils) #:select (get-random-from-dev
                                        get-string-all-with-detected-charset)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;  U T I L I T I E S  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
(define (SALTER password saltString)
  (string->sha-512 (string-append password saltString)))

(define (bv->string bv)
  (string-append/shared (fold
                          (lambda (int final)
                            (string-append final " " (number->string int)))
                          "#vu8("
                          (bytevector->u8-list bv))                         ")"))



(get "/auth/sign_in" #:session #t
  (lambda (rc)
    (if (:session rc 'check)
        (redirect-to rc "/")
      (view-render "sign_in" (the-environment)))))
