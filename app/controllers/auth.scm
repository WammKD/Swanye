;; Controller auth definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models PEOPLE)
             (app models ACTORS)
             (app models ENDPOINTS)
             (artanis sendmail)
             ((artanis utils) #:select (get-random-from-dev
                                        get-string-all-with-detected-charset))
             (ice-9 eval-string)
             (industria crypto blowfish)
             (rnrs bytevectors)
             ((srfi srfi-1)   #:select (fold))
             (srfi srfi-98)
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
        (process-redirect rc "/")
      (view-render "sign_in" (the-environment)))))

(post "/auth/sign_in" #:auth      `(table PEOPLE "USERNAME" "PASSWORD"
                                                 "SALT"     ,SALTER)
                      #:session   #t
                      #:from-post 'qstr-safe
  (lambda (rc)
    (cond
     [(:session rc 'check) (process-redirect rc "/")]
     [(:auth    rc)        (:session rc 'spawn)
                           (process-redirect rc "/")]
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

            (let ([ACTIVITYPUB_ID (string-append/shared "https://" domain
                                                        "/users/"  username)]
                  [ACTOR_TYPE     "Person"])
              ($ACTORS 'set #:AP_ID              (string-reverse ACTIVITYPUB_ID)
                            #:ACTOR_TYPE         ACTOR_TYPE
                            #:INBOX              (string-append/shared ACTIVITYPUB_ID "/inbox")
                            #:OUTBOX             (string-append/shared ACTIVITYPUB_ID "/outbox")
                            #:FOLLOWING          (string-append/shared ACTIVITYPUB_ID "/following")
                            #:FOLLOWERS          (string-append/shared ACTIVITYPUB_ID "/followers")
                            #:LIKED              (string-append/shared ACTIVITYPUB_ID "/likes")
                            #:FEATURED           (string-append/shared ACTIVITYPUB_ID "/collections/featured")
                            #:PREFERRED_USERNAME username
                            #:JSON               (scm->json-string
                                                   `(("@context"          . ("https://www.w3.org/ns/activitystreams"
                                                                             "https://w3id.org/security/v1"))
                                                     ("id"                . ,ACTIVITYPUB_ID)
                                                     ("type"              . ,ACTOR_TYPE)
                                                     ("preferredUsername" . ,username)
                                                     ("inbox"             . (string-append/shared ACTIVITYPUB_ID "/inbox"))
                                                     ("publicKey"         . (("id"           . ,(string-append/shared
                                                                                                  ACTIVITYPUB_ID
                                                                                                  "#main-key"))
                                                                             ("owner"        . ,ACTIVITYPUB_ID)
                                                                             ("publicKeyPem" . ,public))))))

              (let ([ACTOR_ID (cdaar ($ACTORS 'get #:columns   '(ACTOR_ID)
                                                   #:condition (where #:AP_ID (string-reverse ACTIVITYPUB_ID))))])
                ($ENDPOINTS 'set #:ACTOR_ID     ACTOR_ID
                                 #:SHARED_INBOX (string-append/shared "https://" domain "/inbox"))
                ($PEOPLE    'set #:ACTOR_ID           ACTOR_ID
                                 #:USERNAME           username
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
                                 #:PUBLIC_KEY         public
                                 #:PRIVATE_KEY        (bv->string private))))

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
