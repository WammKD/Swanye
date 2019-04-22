;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models    PEOPLE) (ice-9 eval-string) (srfi srfi-1)  ((srfi srfi-19) #:prefix d:)
             (app       models FOLLOWERS) (ice-9     receive) (srfi srfi-26)
             (app       models   INBOXES) (ice-9       regex) (web   client)
             (industria crypto  blowfish) (rnrs  bytevectors) (web  request))

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
          (receive (httpHead httpBody)
              (http-get keyID #:headers `((Accept . ,(string-append/shared
                                                       "application/ld+json; "
                                                       "profile=\"https://www"
                                                       ".w3.org/ns/activity"
                                                       "streams\""))))
            (let* ([username                         (assoc-ref user "USERNAME")]
                   [currentTime                  (number->string (current-time))]
                   [ sigFilename (string-append/shared "/tmp/signature_" username
                                                       currentTime       ".txt")]
                   [baseFilename (string-append/shared "/tmp/sigBase64_" username
                                                       currentTime       ".txt")]
                   [ pubFilename (string-append/shared "/tmp/sigPubKey_" username
                                                       currentTime       ".txt")]
                   [veriFilename (string-append/shared "/tmp/sigVerify_" username
                                                       currentTime       ".txt")]
                   [rsltFilename (string-append/shared "/tmp/sigResult_" username
                                                       currentTime       ".txt")]
                   [bodyFilename (string-append/shared "/tmp/sigDigest_" username
                                                       currentTime       ".txt")]
                   [brltFilename (string-append/shared "/tmp/sigBdRslt_" username
                                                       currentTime       ".txt")]
                   [ sigPort                        (open-file  sigFilename "w")]
                   [ pubPort                        (open-file  pubFilename "w")]
                   [veriPort                        (open-file veriFilename "w")]
                   [bodyPort                        (open-file bodyFilename "w")])
              (display signature sigPort)
              (close sigPort)

              (system (string-append/shared "openssl base64 -d -A -in " sigFilename
                                            " -out "                    baseFilename))
              (system (string-append/shared "rm " sigFilename))

              (display (utf8->string body) bodyPort)
              (close bodyPort)

              (system (string-append/shared "openssl dgst -sha256 -binary " bodyFilename
                                            " | base64 > "                  brltFilename))
              (system (string-append/shared "rm " bodyFilename))

              (display (hash-ref
                         (hash-ref
                           (json-string->scm (utf8->string httpBody))
                           "publicKey")
                         "publicKeyPem")                               pubPort)
              (close pubPort)

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
                                   (if-let ([obj (assoc-ref h (string->symbol
                                                                signedHeaderName))])
                                       (cond
                                        [(d:date? obj) (d:date->string
                                                         obj
                                                         "~a, ~d ~b ~Y ~3 GMT")]
                                        [(pair?   obj) (if-let ([o symbol? (car obj)])
                                                           (symbol->string o)
                                                         o)]
                                        [(string? obj) obj]
                                        [(symbol? obj) (symbol->string obj)]
                                        [else          ""])
                                     "")
                                   "\n"))))
                           ""
                           (string-split headers #\space))) veriPort)
              (close veriPort)

              (system (string-append/shared "openssl dgst -sha256 -verify "  pubFilename
                                            " -signature "                  baseFilename
                                            " "                             veriFilename
                                            " > "                           rsltFilename))
              (system (string-append/shared "rm "  pubFilename))
              (system (string-append/shared "rm " baseFilename))
              (system (string-append/shared "rm " veriFilename))

              (if (string=
                    (string-trim-both
                      (get-string-all-with-detected-charset rsltFilename))
                    "Verified OK")
                  (begin
                    (system (string-append/shared "rm " rsltFilename))

                    (let ([bodyStr (utf8->string body)])
                      ($INBOXES 'set #:PERSON_ID (assoc-ref user "ID")
                                     #:ACTIVITY  bodyStr
                                     #:TYPE      (hash-ref
                                                   (json-string->scm bodyStr)
                                                   "type"))

                      (response-emit "OK" #:status 200)))
                (begin
                  (system (string-append/shared "rm " rsltFilename))

                  (response-emit "Request signature could not be verified"
                                 #:status 401)))))
        (response-emit "Request signature could not be verified" #:status 401)))))
