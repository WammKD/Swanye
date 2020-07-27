;; Controller auth definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models PEOPLE)
             ((artanis utils) #:select (get-random-from-dev
                                        get-string-all-with-detected-charset))
             (rnrs bytevectors))

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



;;;;;;;;;;;;;;;;;;;;;
;;  S I G N - I N  ;;
;;;;;;;;;;;;;;;;;;;;;
(get "/auth/sign_in" #:session #t
  (lambda (rc)
    (if (:session rc 'check)
        (redirect-to rc "/")
      (view-render "sign_in" (the-environment)))))

(post "/auth/sign_in" #:auth      `(table PEOPLE "USERNAME" "PASSWORD"
                                                 "SALT"     ,SALTER)
                      #:session   #t
                      #:from-post 'qstr-safe
  (lambda (rc)
    (cond
     [(:session rc 'check) (redirect-to rc "/")]
     [(:auth    rc)        (:session rc 'spawn)
                           (redirect-to rc "/")]
     [else                   "Go to fail page."])))

;;;;;;;;;;;;;;;;;;;;;
;;  S I G N - I N  ;;
;;;;;;;;;;;;;;;;;;;;;
(auth-define sign_up
  (lambda (rc)
    "<h1>This is auth#sign_up</h1><p>Find me in app/views/auth/sign_up.html.tpl</p>"
    ;; TODO: add controller method `sign_up'
    ;; uncomment this line if you want to render view from template
    (view-render "sign_up" (the-environment))))

(post "/auth/sign_up" #:from-post 'qstr-safe
  (lambda (rc)
    (let ([email     (uri-decode (:from-post rc 'get    "email"))]
          [username  (uri-decode (:from-post rc 'get "username"))]
          [salt                (get-random-from-dev #:length 128)]
          [createdAt                               (current-time)]
          [domain                (car (request-host (rc-req rc)))])
      (let ([token (string->sha-512 (string-append/shared
                                      (number->string createdAt)
                                      email
                                      username))])
        (if (not (null? ($PEOPLE 'get #:columns   '(*)
                                      #:condition (where #:USERNAME username))))
            ;; Stuff
          ;; Other stuff
            )))))
