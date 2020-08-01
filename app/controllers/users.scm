;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models    PEOPLE) (ice-9 eval-string) (srfi srfi-1)  ((srfi srfi-19) #:prefix d:)
             (app       models FOLLOWERS) (ice-9     receive) (srfi srfi-26) (srfi srfi-98)
             (app       models   INBOXES) (ice-9       regex) (web   client)
             (industria crypto  blowfish) (rnrs  bytevectors) (web  request))

(include "../protocols/utils.scm")

(define-syntax process-user-account-as
  (syntax-rules ()
    [(_ userVar (rcVar) then)
          (let ([poss ($PEOPLE
                        'get
                        #:columns   '(*)
                        #:condition (where #:USERNAME (params rcVar "user")))])
            (if (null? poss)
                (redirect-to rcVar (process-uri rcVar "/404"))
              (let ([userVar (car poss)])
                then)))]))

(define (act-stream? accept)
  (or
    (assoc-ref accept 'application/activity+json)
    (let ([ld (assoc-ref accept 'application/ld+json)])
      (and ld (equal?
                (assoc-ref ld 'profile)
                "https://www.w3.org/ns/activitystreams")))))

(define (gsub regexp replacement str)
  (if-let ([isMatch (string-match regexp str)])
      (regexp-substitute #f isMatch 'pre replacement 'post)
    str))




(get "/@:user" #:mime 'json
  (lambda (rc)
    (process-user-account-as user (rc)
      (if-let* ([request                              (rc-req rc)]
                [accept   act-stream?    (request-accept request)]
                [username             (assoc-ref user "USERNAME")])
          (let ([userURL         (string-append/shared
                                   "https://" (car (request-host request))
                                   "/users/"  username)]
                [publicEncrypted (eval-string (assoc-ref user "PUBLIC"))])
            (blowfish-decrypt!
              publicEncrypted 0
              publicEncrypted 0
              (reverse-blowfish-schedule
                (eval-string (get-environment-variable "BLOWFISH_SCHEDULE"))))

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
        (string-append/shared "The user page of " username "!")))))

(get "/users/:user" (lambda (rc)
                      (redirect-to rc (process-uri rc (string-append/shared
                                                        "/@"
                                                        (params rc "user"))))))

(get "/users/:user/followers" #:mime 'json
  (lambda (rc)
    (process-user-account-as user (rc)
      (if-let* ([request                              (rc-req rc)]
                [accept   act-stream?    (request-accept request)]
                [username             (assoc-ref user "USERNAME")])
          (let* ([id        (string-append/shared
                              "https://"   (car (request-host request))
                              "/users/"    username
                              "/followers")]
                 [followers ($FOLLOWERS
                              'get
                              #:columns   '(*)
                              #:condition (where
                                            #:FOLLOWEE
                                            (assoc-ref user "ID")))]
                 [followLen (length followers)])
            (:mime rc (append
                        `(("@context"   . "https://www.w3.org/ns/activitystreams")
                          ("type"       .                     "OrderedCollection")
                          ("totalItems" .                              ,followLen))
                        (if-let ([pgNum (get-from-qstr rc "page")])
                            (let ([num (if-let ([n (string->number
                                                     pgNum)]) (floor n) 1)])
                              (append
                                `(("id" . ,(string-append/shared id "?page=" pgNum)))
                                (if (> num 1)
                                    `(("prev" . ,(string-append/shared
                                                   id
                                                   "?page="
                                                   (number->string (1- num)))))
                                  '())
                                (if (negative?
                                      (/ (- followLen (* num 10) 1) 10))
                                    '()
                                  `(("next" . ,(string-append/shared
                                                 id
                                                 "?page="
                                                 (if (> num 1)
                                                     (number->string (1+ num))
                                                   "2")))))
                                `(("partOf"       . ,id)
                                  ("orderedItems" . ,(map
                                                       (cut assoc-ref <> "FOLLOWER")
                                                       followers)))))
                          `(("id"         .                                  ,id)
                            ("first"      . ,(string-append/shared id "?page=1")))))))
        (string-append/shared "The followers page of " username "!")))))

(post "/users/:user/inbox"
  (lambda (rc)
    (process-user-account-as user (rc)
      (if-let* ([get-val   (lambda (k s)  ; s = signature, k = key, v = value
                             (if-let ([v null? (assoc-ref s k)]) #f (car v)))]
                [body                                            (rc-body rc)]
                [request                                         (rc-req  rc)]
                [h                                  (request-headers request)]
                [sig           (map
                                 (lambda (pair)
                                   (map
                                     (lambda (value)
                                       (gsub "\"$" "" (gsub "^\"" "" value)))
                                     (string-split
                                       (gsub "=" "\n" pair)
                                       #\newline)))
                                 (string-split (assoc-ref h 'signature) #\,))]
                [keyID                              (get-val "keyId"     sig)]
                [headers                            (get-val "headers"   sig)]
                [signature                          (get-val "signature" sig)])
          (begin
            (display "\n\n\n\nFUCKERSHIT\n\n\n\n")
            (display keyID)
            (newline)
            (display headers)
            (newline)
            (display signature)
            (newline)
            (display sig)
            (newline)
            (display h)
            (newline)
            (display request)
            (newline)
            (display (utf8->string body))
            (newline)
            (display "\n\n\n\nFUCKERSHIT2\n\n\n\n")

            (display "DAMNED HELL")
            (newline))
        (response-emit "Request signature could not be verified" #:status 401)))))

(get "/users/follow/:userToFollow" #:with-auth "/auth/sign_in"
  (lambda (rc)
    (let ([poss ($PEOPLE 'get #:columns   '(*)
                              #:condition (where #:USERNAME "wammkd"))])
      (if (null? poss)
          (redirect-to rc (process-uri rc "/404"))
        (let* ([user                                              (car poss)]
               [username                         (assoc-ref user "USERNAME")]
               [userURL          (string-append/shared
                                   "https://" (car (request-host (rc-req rc)))
                                   "/users/"  username)]
               [currentTime                  (number->string (current-time))]
               [currentDate                         (d:date->string
                                                      (d:current-date)
                                                      "~a, ~d ~b ~Y ~3 GMT")]
               [utfName          (car  (string-split (params
                                                       rc
                                                       "userToFollow") #\@))]
               [utfDomain        (cadr (string-split (params
                                                       rc
                                                       "userToFollow") #\@))]
               [utfPath                        (string-append/shared
                                                 "/users/" utfName "/inbox")]
               [utfURL                       (string-append/shared
                                               "https://" utfDomain utfPath)]
               [privateEncrypted    (eval-string (assoc-ref user "PRIVATE"))]
               [baseFilename     (string-append/shared "/tmp/siB64_" username
                                                       currentTime   ".txt")]
               [ sigFilename     (string-append/shared "/tmp/signa_" username
                                                       currentTime   ".txt")]
               [privFilename     (string-append/shared "/tmp/priva_" username
                                                       currentTime   ".txt")]
               [ sigPort                        (open-file  sigFilename "w")]
               [privPort                        (open-file privFilename "w")]
               [stringToSign        (string-append/shared
                                      "(request-target): post " utfPath
                                      "\nhost: "                utfDomain
                                      "\ndate: "                currentDate)])
          (blowfish-decrypt!
            privateEncrypted 0
            privateEncrypted 0
            (reverse-blowfish-schedule
              (eval-string (get-environment-variable "BLOWFISH_SCHEDULE"))))

          (display (utf8->string privateEncrypted) privPort)
          (close privPort)

          (display stringToSign sigPort)
          (close sigPort)

          (system (string-append/shared "openssl dgst -sha256 -sign "  privFilename
                                        " " sigFilename " | base64 > " baseFilename))
          (system (string-append/shared "rm " privFilename " " sigFilename))

          (receive (httpHead httpBody)
              (http-post utfURL #:headers `((Host      . ,utfURL)
                                            (Date      . ,currentDate)
                                            (Signature . ,(string-append/shared
                                                            "keyId=\""
                                                            userURL
                                                            "\",headers=\"(request-target) host date\",signature=\""
                                                            (get-string-all-with-detected-charset baseFilename) "\"")))
                                #:body    (string-append/shared
                                            "{ \"@context\": \"https://www.w3.org/ns/activitystreams\","
                                              "\"id\":       \"" userURL "#follow_at_" currentTime "\","
                                              "\"type\":     \"Follow\","
                                              "\"actor\":    \"" userURL "\","
                                              "\"object\":   \"https://" utfDomain "/users/" utfName "\" }"))
            (system (string-append/shared "rm " baseFilename))

            (string-append
              "It worked!\n\n"
              (utf8->string httpBody))))))))
