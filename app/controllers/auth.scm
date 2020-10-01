;; Controller auth definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models     USERS)
             (app models  SESSIONS)
             (artanis sendmail)
             ((artanis utils) #:select (get-random-from-dev
                                        get-string-all-with-detected-charset))
             (ice-9 eval-string)
             (industria crypto blowfish)
             (rnrs bytevectors)
             ((srfi srfi-1)   #:select (fold))
             (srfi srfi-98)
             (Swanye database-getters)
             (Swanye database-setters)
             (Swanye utils)
             (web request))

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
(auth-define sign_in
  (options #:session #t)

  (lambda (rc)
    (if (:session rc 'check)
        (process-redirect rc "/main/home")
      (view-render "sign_in" (the-environment)))))

(post "/auth/sign_in" #:auth      `(table USERS "PREFERRED_USERNAME" "PASSWORD"
                                                "SALT"               ,SALTER)
                      #:session   #t
                      #:from-post 'qstr-safe
  (lambda (rc)
    (cond
     [(:session rc 'check) (process-redirect rc "/main/home")]
     [(:auth    rc)        (let ([userID (swanye-user-db-id
                                           (car (get-only-user-where
                                                  #:PREFERRED_USERNAME
                                                  (:from-post rc 'get "PREFERRED_USERNAME"))))])
                             (if (null? ($SESSIONS 'get #:columns   '(*)
                                                        #:condition (where
                                                                      #:USER_ID
                                                                      userID)))
                                 ($SESSIONS 'set #:SESSION_ID (:session rc 'spawn)
                                                 #:USER_ID    userID)
                               ($SESSIONS 'set #:SESSION_ID (:session rc 'spawn)
                                               (where #:USER_ID userID))))

                           (process-redirect rc "/main/home")]
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
          [createdAt                               (current-time)])
      (if (not (null? (get-only-user-where #:PREFERRED_USERNAME username)))
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

          (let* ([token    (string->sha-512 (string-append/shared
                                              (number->string createdAt)
                                              email
                                              username))]
                 [salt                    (get-random-from-dev #:length 128)]
                 [domain                    (car (request-host (rc-req rc)))]
                 [private  (string->utf8
                             (string-trim-right
                               (get-string-all-with-detected-charset
                                (string-append "/tmp/" privateFilename))))]
                 [public   (string-trim-right
                             (get-string-all-with-detected-charset
                               (string-append "/tmp/"  publicFilename)))]
                 [schedule (eval-string
                             (get-environment-variable "BLOWFISH_SCHEDULE"))])
            (system (string-append/shared "rm /tmp/" privateFilename))
            (system (string-append/shared "rm /tmp/"  publicFilename))

            (blowfish-encrypt! private 0 private 0 schedule)

            (clear-blowfish-schedule! schedule)

            (insert-user #t domain
                            email
                            (SALTER (uri-decode (:from-post rc 'get "password")) salt)
                            salt
                            createdAt
                            token
                            public
                            (bv->string private)
                            username)

            (send-the-mail ((make-simple-mail-sender
                              (string-append/shared "no-reply@" domain)
                              email
                              #:sender "msmtp")
                             (string-append/shared
                               "Please visit "
                               domain "/auth/confirmation?token=" token
                               " to complete your registration.")
                             #:subject "NO REPLY: Account Confirmation Needed"))

            (view-render "sign_up_success" (the-environment))))))))

;;;;;;;;;;;;;;;;;;;;;;;
;;  P A S S W O R D  ;;
;;;;;;;;;;;;;;;;;;;;;;;
(auth-define password
  (lambda (rc)
    "<h1>This is auth#password</h1><p>Find me in app/views/auth/password.html.tpl</p>"
    ;; TODO: add controller method `password'
    ;; uncomment this line if you want to render view from template
    ;; (view-render "password" (the-environment))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  C O N F I R M A T I O N  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(auth-define confirmation
  (lambda (rc)
    (let ([poss (get-only-user-where #:CONFIRMATION_TOKEN (get-from-qstr rc "token"))])
      (if (null? poss)
          (view-render "confirmation_error" (the-environment))
        (let ([user (car poss)])
          ($USERS 'set #:CONFIRMATION_TOKEN "confirmed"
                       (where #:USER_ID (swanye-user-db-id user)))

          (let ([user (swanye-user-preferred-username user)])
            (view-render "confirmation_success" (the-environment))))))))
