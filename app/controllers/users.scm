;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models   PEOPLE) (ice-9 eval-string)
             (industria crypto blowfish) (rnrs  bytevectors) (web request))

(define (render-user-page rc)
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

(define (act-stream? accept)
  (or
    (assoc-ref accept 'application/activity+json)
    (let ([ld (assoc-ref accept 'application/ld+json)])
      (and ld (equal?
                (assoc-ref ld 'profile)
                "https://www.w3.org/ns/activitystreams")))))
    (process-user-account-as user (rc)
      (let* ([request                  (rc-req rc)]
             [accept      (request-accept request)]
             [username (assoc-ref user "USERNAME")])
        (if (act-stream? accept)
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

              (cons #t `(("@context"          . ("https://www.w3.org/ns/activitystreams"
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
          (cons #f (string-append/shared "The user page of " username "!")))))))



(get "/@:user" #:mime 'json
  (lambda (rcObject)
    (let ([result (render-user-page rcObject)])
      (if (car result)
          (:mime rcObject (cdr result))
        (cdr result)))))

(get "/users/:user" #:mime 'json
  (lambda (rcObject)
    (let ([result (render-user-page rcObject)])
      (if (car result)
          (:mime rcObject (cdr result))
        (cdr result)))))
