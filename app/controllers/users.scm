;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models    PEOPLE) (ice-9 eval-string) (rnrs bytevectors)
             (app       models FOLLOWERS) (ice-9     receive) (web       client)
             (app       models   INBOXES) (srfi      srfi-1)  (web      request)
             (industria crypto  blowfish) (srfi      srfi-26))

(define-syntax if-let-helper
  (syntax-rules ()
    [(_ letVersion
        ([bnd             val]    ...)
        (cnd                      ...)
        ()                             then else) (letVersion ([bnd val] ...)
                                                    (if (and cnd ...) then else))]
    [(_ letVersion
        ([bnd             val]    ...)
        (cnd                      ...)
        ([binding       value] . rest) then else) (if-let-helper letVersion
                                                                 ([bnd val] ... [binding value])
                                                                 (cnd                       ...)
                                                                 rest                            then else)]
    [(_ letVersion
        ([bnd             val]    ...)
        (cnd                      ...)
        ([binding funct value] . rest) then else) (if-let-helper letVersion
                                                                 ([bnd val] ... [binding value])
                                                                 (cnd       ... (funct binding))
                                                                 rest                            then else)]))
(define-syntax if-let
  (syntax-rules ()
    [(_ ([binding         value]  ...) then else) (let ([binding value] ...)
                                                    (if (and binding ...) then else))]
    [(_ (binding-funct-value      ...) then else) (if-let-helper let
                                                                 ()
                                                                 ()
                                                                 (binding-funct-value ...) then else)]))
(define-syntax if-let*
  (syntax-rules ()
    [(_ ([binding         value]  ...) then else) (let* ([binding value] ...)
                                                    (if (and binding ...) then else))]
    [(_ (binding-funct-value      ...) then else) (if-let-helper let*
                                                                 ()
                                                                 ()
                                                                 (binding-funct-value ...) then else)]))

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

(define (gsub regexp replacement str)
  (if-let ([match? (string-match regexp str)])
      (regexp-substitute #f match? 'pre replacement 'post)
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
        (string-append/shared "The user page of " username "!")))))

(get "/users/:user" (lambda (rc)
                      (redirect-to rc (string-append/shared
                                        "/@"
                                        (params rc "user")) #:scheme 'https)))

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
                [request                                          (rc-req rc)]
                [h                                  (request-headers request)]
                [sig           (map
                                 (lambda (pair)
                                   (map
                                     (lambda (value)
                                       (gsub "\"$" "" (gsub "^\"" "" value)))
                                     (string-split pair #\=)))
                                 (string-split (assoc-ref h 'Signature) #\,))]
                [keyID                              (get-val "keyId"     sig)]
                [headers                            (get-val "headers"   sig)]
                [signature (if-let ([v? (get-val "signature" sig)])
                               (base64-decode-as-string v?)
                             #f)])
          (receive (head body)
              (http-get keyID #:headers '((Accept . (string-append/shared
                                                      "application/ld+json; "
                                                      "profile=\"https://www"
                                                      ".w3.org/ns/activity"
                                                      "streams\""))))
            (let* ([username                         (assoc-ref user "USERNAME")]
                   [currentTime                                   (current-time)]
                   [ sigFilename (string-append/shared "/tmp/signature_" username
                                                       currentTime       ".txt")]
                   [baseFilename (string-append/shared "/tmp/sigBase64_" username
                                                       currentTime       ".txt")]
                   [veriFilename (string-append/shared "/tmp/sigVerify_" username
                                                       currentTime       ".txt")]
                   [ sigPort                        (open-file  sigFilename "w")]
                   [basePort                        (open-file baseFilename "w")])
              (display (string-trim-right
                         (fold
                           (lambda (signedHeaderName result)
                             (string-append/shared
                               result
                               (if (string= signedHeaderName "(request-target)")
                                   "(request-target): post /inbox\n"
                                 (string-append/shared
                                   signedHeaderName
                                   ": "
                                   (assoc-ref h (string->symbol
                                                  (string-capitalize
                                                    signedHeaderName)))
                                   "\n"))))
                           ""
                           (string-split headers #\space))) sigPort)
              (close sigPort)

              (system (string-append/shared "openssl base64 -d -in " sigFilename
                                            " -out "                 baseFilename))
              (system (string-append/shared "rm " sigFilename))

              (display (hash-ref
                         (hash-ref
                           (json-string->scm (utf8->string body))
                           "publicKey")
                         "publicKeyPem")                           basePort)
              (close basePort)

              (system (string-append/shared "openssl dgst -sha256 -verify " baseFilename
                                            " -signature "                  veriFilename))
              (system (string-append/shared "rm " baseFilename))

              (if (string=
                    (string-trim-both
                      (get-string-all-with-detected-charset veriFilename))
                    "Verified OK")
                  (begin
                    (system (string-append/shared "rm " veriFilename))

                    (if-let ([body (rc-body rc)])
                        (let ([bodyStr (utf8->string body)])
                          ($INBOXES 'set #:PERSON_ID (assoc-ref user "ID")
                                         #:ACTIVITY  bodyStr
                                         #:TYPE      (hash-ref
                                                       (json-string->scm bodyStr)
                                                       "type"))

                          (response-emit "OK" #:status 200))
                      (response-emit "Request signature could not be verified"
                                     #:status 401)))
                (begin
                  (system (string-append/shared "rm " veriFilename))

                  (response-emit "Request signature could not be verified"
                                 #:status 401)))))
        (response-emit "Request signature could not be verified" #:status 401)))))
