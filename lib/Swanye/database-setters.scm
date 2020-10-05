;;;; This lib file was generated by GNU Artanis, please add your license header below.
;;;; And please respect the freedom of other people, please.
;;;; <YOUR LICENSE HERE>

(define-module (Swanye database-setters)
  #:use-module (srfi             srfi-19)
  #:use-module (web                  uri)
  #:use-module (Swanye  database-getters)
  #:use-module (Swanye             utils)
  #:use-module (artanis            utils)
  #:use-module (artanis third-party                 json)
  #:use-module (app     models                     USERS)
  #:use-module (app     models                    ACTORS)
  #:use-module (app     models                 ENDPOINTS)
  #:use-module (app     models                ACTIVITIES)
  #:use-module (app     models      ACTIVITIES_BY_ACTORS)
  #:use-module (app     models                   OBJECTS)
  #:export (insert-object      insert-activity      insert-actor      insert-user
            insert-object-auto insert-activity-auto insert-actor-auto get-actor-dbID-by-apID))

(define* (insert-object onlyGetID   AP_ID
                        OBJECT_TYPE JSON  #:key ATTRIBUTED_TO CONTENT NAME
                                                STARTTIME     ENDTIME PUBLISHED)
  (let* ([apID    (if (uri? AP_ID) (uri->string AP_ID) AP_ID)]
         [apIDrev                       (string-reverse apID)])
    ($OBJECTS 'set #:AP_ID         apIDrev
                   #:OBJECT_TYPE   OBJECT_TYPE
                   #:ATTRIBUTED_TO (case-pred ATTRIBUTED_TO
                                     [not        'null]
                                     [number?    ATTRIBUTED_TO]
                                     [string?    (get-object-dbID-by-apID ATTRIBUTED_TO)]
                                     [ap-object? (if-let ([at null? (ap-object-attributed-to
                                                                      ATTRIBUTED_TO)])
                                                     'null
                                                   (ap-object-db-id (car at)))])
                   #:CONTENT       (if CONTENT (gsub "'" "''" CONTENT) 'null)
                   #:NAME          (if NAME    (gsub "'" "''" NAME)    'null)
                   #:STARTTIME     (case-pred STARTTIME
                                     [not                             'null]
                                     [string? (time-second
                                                (date->time-utc
                                                  (string->date
                                                    STARTTIME
                                                    "~Y-~m-~dT~H:~M:~SZ")))]
                                     [date?   (time-second
                                                (date->time-utc STARTTIME))]
                                     [time?   (time-second       STARTTIME)])
                   #:ENDTIME       (case-pred ENDTIME
                                     [not                             'null]
                                     [string? (time-second
                                                (date->time-utc
                                                  (string->date
                                                    ENDTIME
                                                    "~Y-~m-~dT~H:~M:~SZ")))]
                                     [date?   (time-second
                                                (date->time-utc   ENDTIME))]
                                     [time?   (time-second         ENDTIME)])
                   #:PUBLISHED     (case-pred PUBLISHED
                                     [not                             'null]
                                     [string? (time-second
                                                (date->time-utc
                                                  (string->date
                                                    PUBLISHED
                                                    "~Y-~m-~dT~H:~M:~SZ")))]
                                     [date?   (time-second
                                                (date->time-utc PUBLISHED))]
                                     [time?   (time-second       PUBLISHED)])
                   #:JSON          (gsub "'" "''" (if (hash-table? JSON)
                                                      (scm->json-string JSON)
                                                    JSON)))

    (if onlyGetID
        (get-object-dbID-by-apID apID)
      (if-let ([obj null? (get-objects-where #:AP_ID apIDrev)])
          #f
        (car obj)))))

(define (insert-object-auto onlyGetID object)
  (let ([ref (if (hash-table? object) hash-ref assoc-ref)])
    (insert-object onlyGetID (ref object "id") (ref object "type")         object
                             #:ATTRIBUTED_TO   (ref object "attributedTo")
                             #:CONTENT         (ref object "content")
                             #:NAME            (ref object "name")
                             #:STARTTIME       (ref object "starttime")
                             #:ENDTIME         (ref object "endtime")
                             #:PUBLISHED       (ref object "published"))))



(define* (insert-activity onlyGetID   AP_ID
                          OBJECT      ACTORS
                          OBJECT_TYPE JSON      #:key ATTRIBUTED_TO CONTENT NAME
                                                      STARTTIME     ENDTIME PUBLISHED)
  (let ([objID (insert-object #t AP_ID
                                 OBJECT_TYPE
                                 JSON
                                 #:ATTRIBUTED_TO ATTRIBUTED_TO
                                 #:CONTENT       CONTENT
                                 #:NAME          NAME
                                 #:STARTTIME     STARTTIME
                                 #:ENDTIME       ENDTIME
                                 #:PUBLISHED     PUBLISHED)])
    (for-each
      (lambda (actor)
        ($ACTIVITIES_BY_ACTORS
          'set
          #:ACTIVITY_ID objID
          #:ACTOR_ID    (get-actor-dbID-by-apID
                          (case-pred actor
                            [      list? (map
                                           (lambda (act)
                                             (if (string? act) act (hash-ref act "id")))
                                           actor)]
                            [    string?                 actor]
                            [hash-table? (hash-ref actor "id")]))))
      ACTORS)

    ($ACTIVITIES 'set #:ACTIVITY_ID objID
                      #:OBJECT_ID   (if-let ([actObjID (get-object-dbID-by-apID
                                                         ((if (hash-table? OBJECT)
                                                              hash-ref
                                                            assoc-ref) OBJECT "id"))])
                                        actObjID
                                      (insert-object-auto #t OBJECT)))

    objID))

(define (insert-activity-auto onlyGetID activity)
  (let ([ref (if (hash-table? activity) hash-ref assoc-ref)])
    (insert-activity
      onlyGetID
      (ref activity "id")
      (ref activity "type")
      (if-let ([obj (lambda (str)
                      (char=? (string-ref
                                (string-trim str)
                                0)                 #\{)) (ref activity "object")])
          (json-string->scm obj)
        obj)
      (if-let ([actors (lambda (str)
                         (or
                           (char=? (string-ref
                                     (string-trim str)
                                     0)                 #\{)
                           (char=? (string-ref
                                     (string-trim str)
                                     0)                 #\[))) (ref activity "actor")])
          (json-string->scm actors)
        actors)
      activity
      #:ATTRIBUTED_TO         (ref activity "attributedTo")
      #:CONTENT               (ref activity "content")
      #:NAME                  (ref activity "name")
      #:STARTTIME             (ref activity "starttime")
      #:ENDTIME               (ref activity "endtime")
      #:PUBLISHED             (ref activity "published"))))



(define* (insert-actor onlyGetID AP_ID              OBJECT_TYPE
                                 INBOX              OUTBOX
                                 PREFERRED_USERNAME JSON        #:key ATTRIBUTED_TO        CONTENT
                                                                      NAME                 STARTTIME
                                                                      ENDTIME              PUBLISHED
                                                                      FOLLOWING            FOLLOWERS
                                                                      LIKED                FEATURED
                                                                      PROXY_URL            OAUTH_AUTHORIZATION_ENDPOINT
                                                                      OAUTH_TOKEN_ENDPOINT PROVIDE_CLIENT_KEY
                                                                      SIGN_CLIENT_KEY      SHARED_INBOX)
  (let ([check-and-convert (lambda (elem)
                             (if (not elem) 'null (if (uri? elem)
                                                      (uri->string elem)
                                                    elem)))]
        [objID             (insert-object #t AP_ID
                                             OBJECT_TYPE
                                             JSON
                                             #:ATTRIBUTED_TO ATTRIBUTED_TO
                                             #:CONTENT       CONTENT
                                             #:NAME          NAME
                                             #:STARTTIME     STARTTIME
                                             #:ENDTIME       ENDTIME
                                             #:PUBLISHED     PUBLISHED)])
    ($ACTORS 'set #:ACTOR_ID           objID
                  #:INBOX              (if (uri? INBOX)  (uri->string INBOX)   INBOX)
                  #:OUTBOX             (if (uri? OUTBOX) (uri->string OUTBOX) OUTBOX)
                  #:FOLLOWING          (check-and-convert FOLLOWING)
                  #:FOLLOWERS          (check-and-convert FOLLOWERS)
                  #:LIKED              (check-and-convert LIKED)
                  #:FEATURED           (check-and-convert FEATURED)
                  #:PREFERRED_USERNAME PREFERRED_USERNAME)

    (when (or PROXY_URL           OAUTH_AUTHORIZATION_ENDPOINT  OAUTH_TOKEN_ENDPOINT
              PROVIDE_CLIENT_KEY  SIGN_CLIENT_KEY               SHARED_INBOX)
      ($ENDPOINTS 'set #:ACTOR_ID                     objID
                       #:PROXY_URL                    (check-and-convert PROXY_URL)
                       #:OAUTH_AUTHORIZATION_ENDPOINT (check-and-convert OAUTH_AUTHORIZATION_ENDPOINT)
                       #:OAUTH_TOKEN_ENDPOINT         (check-and-convert OAUTH_TOKEN_ENDPOINT)
                       #:PROVIDE_CLIENT_KEY           (check-and-convert PROVIDE_CLIENT_KEY)
                       #:SIGN_CLIENT_KEY              (check-and-convert SIGN_CLIENT_KEY)
                       #:SHARED_INBOX                 (check-and-convert SHARED_INBOX)))

    (if onlyGetID
        objID
      (car (get-actors-where #:ACTOR_ID objID)))))

(define (insert-actor-auto onlyGetID actor)
  (let* ([ref       (if (hash-table? actor) hash-ref assoc-ref)]
         [endpoints                     (ref actor "endpoints")])
    (insert-actor
      onlyGetID
      (ref actor "id")                (ref actor "type")
      (ref actor "inbox")             (ref actor "outbox")
      (ref actor "preferredUsername") actor
      #:ATTRIBUTED_TO                 (ref actor "attributedTo")
      #:CONTENT                       (ref actor "content")
      #:NAME                          (ref actor "name")
      #:STARTTIME                     (ref actor "startTime")
      #:ENDTIME                       (ref actor   "endTime")
      #:PUBLISHED                     (ref actor "published")
      #:FOLLOWING                     (ref actor "following")
      #:FOLLOWERS                     (ref actor "followers")
      #:LIKED                         (ref actor "liked")
      #:FEATURED                      (ref actor "featured")
      #:PROXY_URL                     (if endpoints (ref endpoints "proxyUrl")                   #f)
      #:OAUTH_AUTHORIZATION_ENDPOINT  (if endpoints (ref endpoints "oauthAuthorizationEndpoint") #f)
      #:OAUTH_TOKEN_ENDPOINT          (if endpoints (ref endpoints "oauthTokenEndpoint")         #f)
      #:PROVIDE_CLIENT_KEY            (if endpoints (ref endpoints "provideClientKey")           #f)
      #:SIGN_CLIENT_KEY               (if endpoints (ref endpoints "signClientKey")              #f)
      #:SHARED_INBOX                  (if endpoints (ref endpoints "sharedInbox")                #f))))

(define (get-actor-dbID-by-apID activityPubID)
  (if-let* ([convert (lambda (str)
                       (string-reverse (if (uri? str) (uri->string str) str)))]
            ;; This'll, currently, not return everything needed if some of
            ;; the actors are in the database and some aren't
            ;;; Need to adjust this function to handle partially having actors
            [actors  (get-actors-where #:AP_ID (if (list? activityPubID)
                                                   (map convert activityPubID)
                                                 (convert activityPubID)))])
      (if (list? activityPubID)
          (map ap-actor-db-id actors)
        (ap-actor-db-id (car actors)))
    ;; (let ([actor (receive (httpHead httpBody)
    ;;                  (http-get
    ;;                    activityPubID
    ;;                    #:headers `((Accept  . "application/ld+json")
    ;;                                (Profile . "https://www.w3.org/ns/activitystreams")))
    ;;                (json-string->scm (utf8->string httpBody)))])
    ((if (list? activityPubID) car)
      (map
        (lambda (apID)
          (let ([actorFilename (string-append/shared
                                 "actor_"
                                 (number->string (current-time))
                                 (get-random-from-dev #:length 64))])
            (system (string-append/shared
                      "curl -H \"Accept: application/ld+json\" "
                           "-H \"Profile: https://www.w3.org/ns/activitystreams\" "
                           apID " > " actorFilename))

            (let ([actorTbl (json-string->scm
                              (get-string-all-with-detected-charset actorFilename))])
              (system (string-append/shared "rm " actorFilename))

              (insert-actor-auto #t actorTbl))))
        (if (list? activityPubID) activityPubID (list activityPubID))))))



(define* (insert-user onlyGetID          domain
                      E_MAIL             PASSWORD
                      SALT               CREATED_AT
                      CONFIRMATION_TOKEN PUBLIC_KEY
                      PRIVATE_KEY        PREFERRED_USERNAME #:key NAME)
  (let* ([ACTIVITYPUB_ID (string-append/shared "https://" domain
                                               "/users/"  PREFERRED_USERNAME)]
         [OBJECT_TYPE    "Person"]
         [objID          (insert-actor #t ACTIVITYPUB_ID
                                          OBJECT_TYPE
                                          (string-append/shared ACTIVITYPUB_ID "/inbox")
                                          (string-append/shared ACTIVITYPUB_ID "/outbox")
                                          PREFERRED_USERNAME
                                          (scm->json-string
                                            `(("@context"          . ("https://www.w3.org/ns/activitystreams"
                                                                      "https://w3id.org/security/v1"))
                                              ("id"                . ,ACTIVITYPUB_ID)
                                              ("type"              . ,OBJECT_TYPE)
                                              ("preferredUsername" . ,PREFERRED_USERNAME)
                                              ("inbox"             . ,(string-append/shared ACTIVITYPUB_ID "/inbox"))
                                              ("publicKey"         . (("id"           . ,(string-append/shared
                                                                                           ACTIVITYPUB_ID
                                                                                           "#main-key"))
                                                                      ("owner"        . ,ACTIVITYPUB_ID)
                                                                      ("publicKeyPem" . ,PUBLIC_KEY)))))
                                          #:NAME         NAME
                                          #:FOLLOWING    (string-append/shared ACTIVITYPUB_ID "/following")
                                          #:FOLLOWERS    (string-append/shared ACTIVITYPUB_ID "/followers")
                                          #:LIKED        (string-append/shared ACTIVITYPUB_ID "/likes")
                                          #:FEATURED     (string-append/shared ACTIVITYPUB_ID "/collections/featured")
                                          #:SHARED_INBOX (string-append/shared "https://" domain "/inbox"))])

    ($USERS 'set #:USER_ID            objID
                 #:PREFERRED_USERNAME PREFERRED_USERNAME
                 #:E_MAIL             E_MAIL
                 #:PASSWORD           PASSWORD
                 #:SALT               SALT
                 #:CREATED_AT         CREATED_AT
                 #:CONFIRMATION_TOKEN CONFIRMATION_TOKEN
                 #:PUBLIC_KEY         PUBLIC_KEY
                 #:PRIVATE_KEY        PRIVATE_KEY)

    (if onlyGetID
        objID
      (car (get-users-where #:USER_ID objID)))))
