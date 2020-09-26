;;;; This lib file was generated by GNU Artanis, please add your license header below.
;;;; And please respect the freedom of other people, please.
;;;; <YOUR LICENSE HERE>

(define-module (Swanye database)
  #:use-module (artanis utils)
  #:use-module (Swanye  utils)
  #:use-module (app models     USERS)
  #:use-module (app models    ACTORS)
  #:use-module (app models ENDPOINTS)
  #:use-module (app models   OBJECTS)
  #:export (lookup-remote-account))

(define (lookup-and-add-remote-account activityPubID)
  (let* ([revActorID            (string-reverse activityPubID)]
         [actors     ($ACTORS
                       'get
                       #:columns   '(ACTOR_ID)
                       #:condition (where #:AP_ID revActorID))])
    (if (not (null? actors))
        (cdaar actors)
      ;; (let ([actor (receive (httpHead httpBody)
      ;;                  (http-get
      ;;                    activityPubID
      ;;                    #:headers `((Accept  . "application/ld+json")
      ;;                                (Profile . "https://www.w3.org/ns/activitystreams")))
      ;;                (json-string->scm (utf8->string httpBody)))])
      (let ([actorFilename (string-append/shared
                             "actor_"
                             (number->string (current-time))
                             (get-random-from-dev #:length 64))])
        (system (string-append/shared
                  "curl -H \"Accept: application/ld+json\" "
                       "-H \"Profile: https://www.w3.org/ns/activitystreams\" "
                  activityPubID
                  " > " actorFilename))

        (let ([actor (json-string->scm
                       (get-string-all-with-detected-charset actorFilename))])
          (system (string-append/shared "rm " actorFilename))

          ($OBJECTS 'set #:AP_ID       revActorID
                         #:OBJECT_TYPE (hash-ref actor "type")
                         #:CONTENT     (if-let ([content (hash-ref actor "content")])
                                           content
                                         'null)
                         #:NAME        (if-let ([name (hash-ref actor "name")])
                                           name
                                         'null)
                         #:STARTTIME   (if-let ([starttime (hash-ref actor "starttime")])
                                           starttime
                                         'null)
                         #:ENDTIME     (if-let ([endtime (hash-ref actor "endtime")])
                                           endtime
                                         'null)
                         #:JSON        (scm->json-string actor))

          (let ([OBJECT_ID (cdaar ($OBJECTS
                                    'get
                                    #:columns   '(OBJECT_ID)
                                    #:condition (where #:AP_ID revActorID)))])
            ($ACTORS 'set #:ACTOR_ID           OBJECT_ID
                          #:AP_ID              revActorID
                          #:ACTOR_TYPE         (hash-ref actor "type")
                          #:INBOX              (hash-ref actor "inbox")
                          #:OUTBOX             (hash-ref actor "outbox")
                          #:FOLLOWING          (if-let ([following (hash-ref actor "following")])
                                                   following
                                                 'null)
                          #:FOLLOWERS          (if-let ([followers (hash-ref actor "followers")])
                                                   followers
                                                 'null)
                          #:LIKED              (if-let ([liked     (hash-ref actor     "liked")])
                                                   liked
                                                 'null)
                          #:FEATURED           (if-let ([featured  (hash-ref actor  "featured")])
                                                   featured
                                                 'null)
                          #:PREFERRED_USERNAME (hash-ref actor "preferredUsername"))

            (let ([ACTOR_ID  (cdaar ($ACTORS
                                      'get
                                      #:columns   '(ACTOR_ID)
                                      #:condition (where #:AP_ID revActorID)))]
                  [endpoints (hash-ref actor "endpoints")])
              (when endpoints
                ($ENDPOINTS 'set #:ACTOR_ID
                                    ACTOR_ID
                                 #:PROXY_URL
                                    (if-let ([proxyURL (hash-ref endpoints "proxyUrl")])
                                        proxyURL
                                      'null)
                                 #:OAUTH_AUTHORIZATION_ENDPOINT
                                    (if-let ([oauthAuthorizationEndpoint (hash-ref
                                                                           endpoints
                                                                           "oauthAuthorizationEndpoint")])
                                        oauthAuthorizationEndpoint
                                      'null)
                                 #:OAUTH_TOKEN_ENDPOINT
                                    (if-let ([oauthTokenEndpoint (hash-ref
                                                                   endpoints
                                                                   "oauthTokenEndpoint")])
                                        oauthTokenEndpoint
                                      'null)
                                 #:PROVIDE_CLIENT_KEY
                                    (if-let ([provideClientKey (hash-ref
                                                                 endpoints
                                                                 "provideClientKey")])
                                        provideClientKey
                                      'null)
                                 #:SIGN_CLIENT_KEY
                                    (if-let ([signClientKey (hash-ref
                                                              endpoints
                                                              "signClientKey")])
                                        signClientKey
                                      'null)
                                 #:SHARED_INBOX
                                    (if-let ([sharedInbox (hash-ref
                                                            endpoints
                                                            "sharedInbox")])
                                        sharedInbox
                                      'null)))

              ACTOR_ID)))))))
