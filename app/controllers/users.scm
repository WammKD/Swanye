;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models   PEOPLE) (ice-9 eval-string)
             (industria crypto blowfish) (rnrs  bytevectors) (web request))

(get "/users/:user" (lambda (rc)
                      (redirect-to
                        rc
                        (string-append/shared "/@" (params rc "user"))
                        #:status 200)))

(get "/@:user" #:mime 'json #:conn #t
  (lambda (rc)
    (let ([poss ($PEOPLE 'get #:columns   '(*)
                              #:condition (where #:USERNAME (params rc "user")))])
      (if (null? poss)
          (redirect-to rc "/404")
        (let* ([request                  (rc-req rc)]
               [accept      (request-accept request)]
               [user                      (car poss)]
               [username (assoc-ref user "USERNAME")])
          (if (or
                (assoc-ref accept 'application/activity+json)
                (let ([ld (assoc-ref accept 'application/ld+json)])
                  (and ld (assoc-ref ld 'profile) (string=?
                                                    (assoc-ref ld 'profile)
                                                    "https://www.w3.org/ns/activitystreams"))))
              (let ([userURL         (string-append/shared
                                       "https://" (car (request-host request))
                                       "/users/"  username)]
                    [publicEncrypted (eval-string (assoc-ref user "PUBLIC"))])
                (blowfish-decrypt!
                  publicEncrypted 0
                  publicEncrypted 0
                  (reverse-blowfish-schedule
                    (eval-string
                      (get-string-all-with-detected-charset "/myapp/.key"))))

                (:mime rc `(("@context"          . ("https://www.w3.org/ns/activitystreams"
                                                    "https://w3id.org/security/v1"))
                            ("id"                . ,userURL)
                            ("type"              . "Person")
                            ("preferredUsername" . ,(assoc-ref user "NAME"))
                            ("inbox"             . ,(string-append/shared
                                                      userURL
                                                      "/inbox"))
                            ("publicKey"         . (("id"           . ,(string-append/shared
                                                                         userURL
                                                                         "#main-key"))
                                                    ("owner"        . ,userURL)
                                                    ("publicKeyPem" . ,(utf8->string
                                                                         publicEncrypted)))))))
            (string-append/shared "The user page of " username "!")))))))
