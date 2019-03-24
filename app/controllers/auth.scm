;; Controller auth definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models PEOPLE) (artanis sendmail) (srfi srfi-1) (web request))

(define (SALTER password saltString)
  (string->sha-512 (string-append password saltString)))



(get "/auth/sign_in" #:session #t
  (lambda (rc)
    (if (:session rc 'check)
        "Replace this with the home page, once developed."
      (view-render "sign_in" (the-environment)))))

(post "/auth/sign_in" #:auth    `(table PEOPLE "USERNAME" "PASSWORD"
                                               "SALT"     ,SALTER)
                      #:session #t
  (lambda (rc)
    (cond
     [(:session rc 'check) "Go to home page."]
     [(:auth    rc)        (:session rc 'spawn)
                           "Go to home page."]
     [else                 "Go to fail page."])))

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
          [createdAt                               (current-time)])
      (let ([token (string->sha-512 (string-append/shared
                                      (number->string createdAt)
                                      email
                                      username))])
        (if (not (null? ($PEOPLE 'get #:columns   '(*)
                                      #:condition (where #:USERNAME username))))
            (view-render "sign_up_error" (the-environment))
          (begin
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
                          #:CONFIRMATION_TOKEN token)

            (send-the-mail ((make-simple-mail-sender
                              "no-reply@swanye.herokuapp.com"
                              email
                              #:sender "/usr/sbin/sendmail")
                             (string-append/shared
                               "Please visit "
                               "http://localhost/auth/confirmation?token="
                               token
                               " to complete your registration.")
                             #:subject "NO REPLY: Account Confirmation Needed"))

            (view-render "sign_up_success" (the-environment))))))))

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

          (view-render "confirmation_success" (the-environment)))))))
