;; Controller users definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller users) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models     USERS) (ice-9 eval-string) (srfi srfi-1)                (Swanye               utils)
             (app       models    ACTORS) (ice-9     receive) ((srfi srfi-19) #:prefix d:) (Swanye database-operations)
             (app       models ENDPOINTS) (ice-9       regex) (srfi srfi-26)               (web                 client)
             (app       models   OBJECTS) (rnrs  bytevectors) (srfi srfi-98)               (web                request)
             (app       models TIMELINES)
             (app       models FOLLOWERS)
             (app       models   INBOXES)
             (industria crypto  blowfish))

(define-syntax process-user-account-as
  (syntax-rules ()
    [(_ userVar (rcVar) then ...)
          (let ([poss (get-users-where #:PREFERRED_USERNAME (params rcVar "user"))])
            (if (null? poss)
                (process-redirect rcVar "/404")
              (let ([userVar (car poss)])
                then ...)))]))

(define (act-stream? accept)
  (or
    (assoc-ref accept 'application/activity+json)
    (let ([ld (assoc-ref accept 'application/ld+json)])
      (and ld (equal?
                (assoc-ref ld 'profile)
                "https://www.w3.org/ns/activitystreams")))))




(get "/@:user" #:mime 'json
  (lambda (rc)
    (process-user-account-as user (rc)
      (if-let* ([request                                        (rc-req rc)]
                [accept   act-stream?              (request-accept request)]
                [username             (swanye-user-preferred-username user)])
          (let ([userURL (uri->string (swanye-user-ap-id user))])
            (:mime rc `(("@context"          . ("https://www.w3.org/ns/activitystreams"
                                                "https://w3id.org/security/v1"))
                        ("id"                . ,userURL)
                        ("type"              . "Person")
                        ("preferredUsername" . ,username)
                        ("inbox"             . ,(uri->string (swanye-user-inbox user)))
                        ("publicKey"         . (("id"           . ,(string-append/shared
                                                                     userURL
                                                                     "#main-key"))
                                                ("owner"        . ,userURL)
                                                ("publicKeyPem" . ,(swanye-user-public-key user)))))))
        (string-append/shared "The user page of " username "!")))))

(users-define :user
  (lambda (rc)
    (process-redirect rc (string-append/shared "/@" (params rc "user")))))

(users-define :user/followers
  (options #:mime 'json)

  (lambda (rc)
    (process-user-account-as user (rc)
      (if-let* ([request                                        (rc-req rc)]
                [accept   act-stream?              (request-accept request)]
                [username             (swanye-user-preferred-username user)])
          (let* ([id        (swanye-user-followers user)]
                 [followers      (get-followers-of user)]
                 [followLen           (length followers)])
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
                                  ("orderedItems" . ,(map ap-actor-ap-id followers)))))
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
            ;; (receive (httpHead httpBody)
            ;;   (http-get keyID #:headers `((Accept  . "application/ld+json")
            ;;                               (Profile . "https://www.w3.org/ns/activitystreams")))

            (let* ([username               (swanye-user-preferred-username user)]
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
                   [bodyPort                        (open-file bodyFilename "w")]
                   ;; remove this, later
                   [profFilename (string-append "/tmp/prof_" (get-random-from-dev #:length 64) ".json")])
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

              ;; Remove this, later
              (system (string-append/shared
                        "curl -H \"Accept: application/ld+json\" "
                             "-H \"Profile: https://www.w3.org/ns/activitystreams\" "
                              keyID
                             " > " profFilename))

              (display "\n\n\n\n")
              (display (get-string-all-with-detected-charset profFilename))
              (display "\n\n\n\n")

              (display (hash-ref
                         (hash-ref           ;; replace with (utf8->string httpBody)
                           (json-string->scm (get-string-all-with-detected-charset profFilename))
                           "publicKey")
                         "publicKeyPem")                               pubPort)
              (close pubPort)

              ;; Remove this, later
              (system (string-append "rm " profFilename))

              (display (string-trim-right
                         (fold
                           (lambda (signedHeaderName result)
                             (string-append/shared
                               result
                               (if (string= signedHeaderName "(request-target)")
                                   (string-append
                                     "(request-target): "
                                     (string-downcase
                                       (symbol->string (request-method request)))
                                     " "
                                     (request-path request)
                                     "\n")
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

                    (let* ([bodyStr             (utf8->string body)]
                           [bodyHash     (json-string->scm bodyStr)]
                           [   actorID  (hash-ref bodyHash "actor")]
                           [revActorID     (string-reverse actorID)]
                           [object     (hash-ref bodyHash "object")])
                      ;; Add the object of the Activity to the DB
                      (when (hash-table? object)
                        ($OBJECTS 'set #:AP_ID         (string-reverse
                                                         (hash-ref object "id"))
                                       #:OBJECT_TYPE   (hash-ref object "type")
                                       #:ATTRIBUTED_TO (if-let ([attributedTo (hash-ref object "attributedTo")])
                                                           (lookup-and-add-remote-account attributedTo)
                                                         'null)
                                       #:CONTENT       (if-let ([content (hash-ref object "content")])
                                                           content
                                                         'null)
                                       #:NAME          (if-let ([name (hash-ref object "name")])
                                                           (gsub "'" "''" name)
                                                         'null)
                                       #:STARTTIME     (if-let ([starttime (hash-ref object "starttime")])
                                                           starttime
                                                         'null)
                                       #:ENDTIME       (if-let ([endtime (hash-ref object "endtime")])
                                                           endtime
                                                         'null)
                                       #:JSON          (gsub "'" "''" (scm->json-string object))))
                      ;; If creating an Object, make sure the object we just added is in the user's timeline
                      (cond
                       [(string=? (hash-ref bodyHash "type") "Create")
                             ($TIMELINES 'set #:USER_ID   (assoc-ref user "USER_ID")
                                              #:OBJECT_ID (cdaar ($OBJECTS
                                                                   'get
                                                                   #:columns   '(OBJECT_ID)
                                                                   #:condition (where
                                                                                 #:AP_ID
                                                                                 (string-reverse
                                                                                   (hash-ref object "id"))))))])
                      ;; Add the actor who did the Activity to the DB
                      ;; (likely taken care of by ATTRIBUTED_TO but let's be thorough)
                      (lookup-and-add-remote-account actorID)
                      ;; Finally, add the Activity to the INBOX
                      ($INBOXES 'set #:USER_ID       (assoc-ref user "USER_ID")
                                     #:ACTOR_ID      (cdaar ($ACTORS
                                                              'get
                                                              #:columns   '(ACTOR_ID)
                                                              #:condition (where #:AP_ID revActorID)))
                                     #:OBJECT_ID     (cdaar ($OBJECTS
                                                              'get
                                                              #:columns   '(OBJECT_ID)
                                                              #:condition (where
                                                                            #:AP_ID
                                                                            (string-reverse
                                                                              (if (hash-table? object)
                                                                                  (hash-ref object "id")
                                                                                object)))))
                                     #:ACTIVITY      bodyStr
                                     #:ACTIVITY_TYPE (hash-ref bodyHash "type"))

                      (response-emit "OK" #:status 200)))
                (begin
                  (system (string-append/shared "rm " rsltFilename))

                  (response-emit "Request signature could not be verified"
                                 #:status 401))))
        (response-emit "Request signature could not be verified" #:status 401)))))

(users-define follow/:userToFollow
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (let ([poss ($USERS 'get #:columns   '(*)
                             #:condition (where #:USERNAME "wammkd"))])
      (if (null? poss)
          (process-redirect rc "/404")
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
