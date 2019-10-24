;; Controller auth definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models PEOPLE)
             (artanis sendmail)
             ((artanis utils) #:select (get-random-from-dev
                                        get-string-all-with-detected-charset))
             (ice-9 eval-string)
             (industria crypto blowfish)
             (rnrs bytevectors)
             ((srfi srfi-1)   #:select (fold))
             (web request))

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
            (view-render "sign_up_error" (the-environment))
          (let ([privateFilename (string-append "private_" username ".pem")]
                [ publicFilename (string-append  "public_" username ".pem")])
            (system (string-append/shared
                      "cd /tmp; openssl genrsa -out "
                      privateFilename
                      " 2048"))
            (system (string-append/shared
                      "cd /tmp; openssl rsa -in "
                      privateFilename
                      " -outform PEM -pubout -out "
                      publicFilename))

            (let ([private  (string->utf8
                              (string-trim-right
                                (get-string-all-with-detected-charset
                                  (string-append "/tmp/" privateFilename))))]
                  [public   (string->utf8
                              (string-trim-right
                                (get-string-all-with-detected-charset
                                  (string-append "/tmp/"  publicFilename))))]
                  [schedule (eval-string (get-string-all-with-detected-charset
                                           "/myapp/.key"))])
              (system (string-append/shared "rm /tmp/" privateFilename))
              (system (string-append/shared "rm /tmp/"  publicFilename))

              (blowfish-encrypt! private 0 private 0 schedule)
              (blowfish-encrypt! public  0 public  0 schedule)

              (clear-blowfish-schedule! schedule)

              ($PEOPLE 'set #:USERNAME           username
                            #:E_MAIL             email
                            #:PASSWORD           (SALTER
                                                   (uri-decode (:from-post
                                                                 rc
                                                                 'get
                                                                 "password"))
                                                   salt)
                            #:SALT               salt
                            #:CREATED_AT         createdAt
                            #:CONFIRMATION_TOKEN token
                            #:PUBLIC             (bv->string  public)
                            #:PRIVATE            (bv->string private))

              (send-the-mail ((make-simple-mail-sender
                                (string-append/shared "no-reply@" domain)
                                email
                                #:sender "/usr/bin/msmtp")
                               (string-append/shared
                                 "Please visit "
                                 domain "/auth/confirmation?token=" token
                                 " to complete your registration.")
                               #:subject "NO REPLY: Account Confirmation Needed"))

              (view-render "sign_up_success" (the-environment)))))))))

(auth-define password
  (lambda (rc)
  "<h1>This is auth#password</h1><p>Find me in app/views/auth/password.html.tpl</p>"
  ;; TODO: add controller method `password'
  ;; uncomment this line if you want to render view from template
  ;; (view-render "password" (the-environment))
  ))

(auth-define confirmation
  (lambda (rc)
    (let ([poss ($PEOPLE 'get #:columns   '(*)
                              #:condition (where
                                            #:CONFIRMATION_TOKEN
                                            (get-from-qstr rc "token")))])
      (if (null? poss)
          (view-render "confirmation_error" (the-environment))
        (let ([person (car poss)])
          ($PEOPLE 'set #:CONFIRMATION_TOKEN "confirmed"
                        (where #:ID (assoc-ref person "ID")))

          (let ([person (assoc-ref person "USERNAME")])
            (view-render "confirmation_success" (the-environment))))))))
