;; Controller auth definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (artanis sendmail) (srfi srfi-1))

(define (SALTER password saltString)
  (string->sha-512 (string-append password saltString)))



(auth-define sign_in
  (lambda (rc)
    "<h1>This is auth#sign_in</h1><p>Find me in app/views/auth/sign_in.html.tpl</p>"
    ;; TODO: add controller method `sign_in'
    ;; uncomment this line if you want to render view from template
    ;; (view-render "sign_in" (the-environment))
  ))

(auth-define sign_up
  (lambda (rc)
    "<h1>This is auth#sign_up</h1><p>Find me in app/views/auth/sign_up.html.tpl</p>"
    ;; TODO: add controller method `sign_up'
    ;; uncomment this line if you want to render view from template
    (view-render "sign_up" (the-environment))))

(post "/auth/sign_up" #:from-post 'qstr-safe #:conn #t
  (lambda (rc)
    (let ([mtable                  (map-table-from-DB (:conn rc))]
          [email     (uri-decode (:from-post rc 'get    "email"))]
          [username  (uri-decode (:from-post rc 'get "username"))]
          [salt                (get-random-from-dev #:length 128)]
          [createdAt                               (current-time)])
      (let ([token (string->sha-512 (string-append/shared
                                      (number->string createdAt)
                                      email
                                      username))])
        (if (any
              (lambda (element)
                (string=? (assoc-ref element "USERNAME") username))
              (mtable 'get 'PEOPLE #:columns '(USERNAME)))
            (view-render "sign_up_error" (the-environment))
          (begin
            (mtable 'set 'PEOPLE #:USERNAME           username
                                 #:E_MAIL             email
                                 #:PASSWORD           (SALTER
                                                        (uri-decode
                                                          (:from-post
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
                               "Please visit http://localhost/auth/confirmation?token="
                               token
                               " to complete your registration.")
                             #:subject "NO REPLY: Account Confirmation Needed"))

            email))))))

(auth-define password
  (lambda (rc)
  "<h1>This is auth#password</h1><p>Find me in app/views/auth/password.html.tpl</p>"
  ;; TODO: add controller method `password'
  ;; uncomment this line if you want to render view from template
  ;; (view-render "password" (the-environment))
  ))

(auth-define confirmation
  (lambda (rc)
  "<h1>This is auth#confirmation</h1><p>Find me in app/views/auth/confirmation.html.tpl</p>"
  ;; TODO: add controller method `confirmation'
  ;; uncomment this line if you want to render view from template
  ;; (view-render "confirmation" (the-environment))
  ))

