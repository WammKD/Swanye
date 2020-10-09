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
  #:use-module (app     models                ADDRESSING)
  #:use-module (app     models                   OBJECTS)
  #:use-module (app     models                 TIMELINES)
  #:export (insert-object      insert-image           insert-activity
            insert-object-auto insert-image-auto      insert-activity-auto
            insert-actor       insert-user
            insert-actor-auto  get-actor-dbID-by-apID))

(define* (insert-object onlyGetID   AP_ID
                        OBJECT_TYPE TO
                        BTO         CC
                        BCC         JSON  #:key ATTRIBUTED_TO CONTENT NAME   STARTTIME
                                                ENDTIME       ICONS   IMAGES PUBLISHED URL)
  (define (insert-addressing actors type objectID)
    (for-each
      (lambda (actor)
        ($ADDRESSING
          'set
          #:OBJECT_ID       objectID
          #:ADDRESSING_TYPE type
          #:ACTOR_ID        (get-actor-dbID-by-apID (if (string? actor)
                                                        actor
                                                      ((if (hash-table? actor)
                                                           hash-ref
                                                         assoc-ref) actor "id")))))
      (if (string? actors) (list actors) (return-if actors '()))))

  (let* ([apID    (if (uri? AP_ID) (uri->string AP_ID) (return-if AP_ID ""))]
         [apIDrev                                      (string-reverse apID)])
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
                   #:URL           (string-reverse (if (uri? AP_ID)
                                                       (uri->string AP_ID)
                                                     (return-if AP_ID "")))
                   #:JSON          (gsub "'" "''" (if (hash-table? JSON)
                                                      (scm->json-string JSON)
                                                    JSON)))

    (let* ([obj      (if onlyGetID
                         (get-object-dbID-by-apID apID)
                       (car (get-objects-where #:AP_ID apIDrev)))]
           [objID (if (ap-object? obj) (ap-object-db-id obj) obj)])
      (insert-addressing  TO  "to" objID)
      (insert-addressing BTO "bto" objID)
      (insert-addressing  CC  "cc" objID)
      (insert-addressing BCC "bcc" objID)

      (when ICONS  (insert-image-auto #t #t objID ICONS))
      (when IMAGES (insert-image-auto #t #f objID IMAGES))

      obj)))

(define (insert-object-auto onlyGetID object)
  (let ([ref (if (hash-table? object) hash-ref assoc-ref)])
    (insert-object onlyGetID (ref object "id") (ref object "type")
                             (ref object "to") (ref object "bto")
                             (ref object "cc") (ref object "bcc")          object
                             #:ATTRIBUTED_TO   (ref object "attributedTo")
                             #:CONTENT         (ref object "content")
                             #:NAME            (ref object "name")
                             #:STARTTIME       (ref object "starttime")
                             #:ENDTIME         (ref object "endtime")
                             #:ICONS           (ref object "icon")
                             #:IMAGES          (ref object "image")
                             #:PUBLISHED       (ref object "published")
                             #:URL             (ref object "url"))))



(define* (insert-image onlyGetID   isIcon    AP_ID
                       OBJECT_TYPE OBJECT_ID JSON  #:key WIDTH         HEIGHT
                                                          TO            CC
                                                         BTO           BCC
                                                         ATTRIBUTED_TO CONTENT
                                                         STARTTIME     NAME
                                                           ENDTIME     PUBLISHED
                                                         ICONS         IMAGES    URL)
  (let ([objID (insert-object #t AP_ID
                                 OBJECT_TYPE
                                 (return-if  TO '())
                                 (return-if BTO '())
                                 (return-if  CC '())
                                 (return-if BCC '())
                                 JSON
                                 #:ATTRIBUTED_TO ATTRIBUTED_TO
                                 #:CONTENT       CONTENT
                                 #:NAME          NAME
                                 #:STARTTIME     STARTTIME
                                 #:ENDTIME       ENDTIME
                                 #:ICONS         ICONS
                                 #:IMAGES        IMAGES
                                 #:PUBLISHED     PUBLISHED
                                 #:URL           URL)])
    ($IMAGES 'set #:IMAGE_ID objID #:OBJECT_ID OBJECT_ID
                  #:WIDTH    WIDTH #:HEIGHT    HEIGHT    #:IS_ICON (if isIcon 0 1))

    (if onlyGetID
        objID
      (car ((if isIcon get-icons-where get-images-where) #:IMAGE_ID objID)))))

(define (insert-image-auto onlyGetID isIcon objectID image)
  (let ([ref (if (hash-table? image) hash-ref assoc-ref)])
    (insert-image onlyGetID        isIcon
                  (ref image "id") (ref image "type")
                  objectID         image
                  #:WIDTH          (ref image "width")
                  #:HEIGHT         (ref image "height")
                  #:TO             (ref image  "to")
                  #:BTO            (ref image "bto")
                  #:CC             (ref image  "cc")
                  #:BCC            (ref image "bcc")
                  #:ATTRIBUTED_TO  (ref image "attributedTo")
                  #:CONTENT        (ref image "content")
                  #:NAME           (ref image "name")
                  #:STARTTIME      (ref image "starttime")
                  #:ENDTIME        (ref image "endtime")
                  #:ICONS          (ref image "icon")
                  #:IMAGES         (ref image "image")
                  #:PUBLISHED      (ref image "published")
                  #:URL            (ref image "url"))))



(define* (insert-activity onlyGetID userID
                          AP_ID     OBJECT_TYPE
                          ACTORS    OBJECT      JSON #:key  TO      CC   ATTRIBUTED_TO CONTENT
                                                           BTO     BCC   NAME          STARTTIME
                                                           ENDTIME ICONS IMAGES        PUBLISHED URL)
  (let ([objID (insert-object #t AP_ID
                                 OBJECT_TYPE
                                 (return-if  TO '())
                                 (return-if BTO '())
                                 (return-if  CC '())
                                 (return-if BCC '())
                                 JSON
                                 #:ATTRIBUTED_TO ATTRIBUTED_TO
                                 #:CONTENT       CONTENT
                                 #:NAME          NAME
                                 #:STARTTIME     STARTTIME
                                 #:ENDTIME       ENDTIME
                                 #:ICONS         ICONS
                                 #:IMAGES        IMAGES
                                 #:PUBLISHED     PUBLISHED
                                 #:URL           URL)])
    (for-each
      (lambda (actor)
        ($ACTIVITIES_BY_ACTORS
          'set  ;; check is 'set can handle multiple #:ACTOR_IDs, later
          #:ACTIVITY_ID objID
          #:ACTOR_ID    (get-actor-dbID-by-apID  ;; maybe adjust to use the object
                          (case-pred actor       ;; rather than make another HTTP call
                            [      list? (assoc-ref actor "id")]
                            [    string?                  actor]
                            [hash-table? ( hash-ref actor "id")]))))
      (if (list? ACTORS) ACTORS (list ACTORS)))

    (let ([activityObjectID (if-let ([actObjID (get-object-dbID-by-apID OBJECT)])
                                actObjID
                              (insert-object-auto #t OBJECT))])
      ($ACTIVITIES 'set #:ACTIVITY_ID objID #:OBJECT_ID activityObjectID)

      (cond
       [(string=? OBJECT_TYPE "Create")
             ($TIMELINES 'set #:USER_ID userID #:OBJECT_ID activityObjectID)]))

    (if onlyGetID
        objID
      (car (get-activities-where #:ACTIVITY_ID objID)))))

(define (insert-activity-auto onlyGetID userID activity)
  (let ([ref (if (hash-table? activity) hash-ref assoc-ref)])
    (insert-activity onlyGetID              userID
                     (ref activity "id")    (ref activity "type")
                     (ref activity "actor") (ref activity "object")       activity
                     #:TO                   (ref activity  "to")
                     #:BTO                  (ref activity "bto")
                     #:CC                   (ref activity  "cc")
                     #:BCC                  (ref activity "bcc")
                     #:ATTRIBUTED_TO        (ref activity "attributedTo")
                     #:CONTENT              (ref activity "content")
                     #:NAME                 (ref activity "name")
                     #:STARTTIME            (ref activity "starttime")
                     #:ENDTIME              (ref activity "endtime")
                     #:ICONS                (ref activity "icon")
                     #:IMAGES               (ref activity "image")
                     #:PUBLISHED            (ref activity "published")
                     #:URL                  (ref activity "url"))))



(define* (insert-actor onlyGetID AP_ID              OBJECT_TYPE
                                 INBOX              OUTBOX
                                 PREFERRED_USERNAME JSON        #:key  TO                   CC
                                                                      BTO                  BCC
                                                                      ATTRIBUTED_TO        CONTENT
                                                                      NAME                 STARTTIME
                                                                      ENDTIME              ICONS
                                                                      IMAGES               PUBLISHED
                                                                      SUMMARY              URL
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
                                             (return-if  TO '())
                                             (return-if BTO '())
                                             (return-if  CC '())
                                             (return-if BCC '())
                                             JSON
                                             #:ATTRIBUTED_TO ATTRIBUTED_TO
                                             #:CONTENT       CONTENT
                                             #:NAME          NAME
                                             #:STARTTIME     STARTTIME
                                             #:ENDTIME       ENDTIME
                                             #:PUBLISHED     PUBLISHED
                                             #:URL           URL)])
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
      #:ICONS                         (ref actor "icon")
      #:IMAGES                        (ref actor "image")
      #:PUBLISHED                     (ref actor "published")
      #:SUMMARY                       (ref actor "summary")
      #:URL                           (ref actor "url")
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
  (if-let* ([convert                (lambda (str)
                                      (string-reverse
                                        (if (uri? str) (uri->string str) str)))]
            ;; This'll, currently, not return everything needed if some of
            ;; the actors are in the database and some aren't
            ;;; Need to adjust this function to handle partially having actors
            [actors  (negate null?) (get-actors-where #:AP_ID (if (list? activityPubID)
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
    ((if (list? activityPubID) identity car)
      (map
        (lambda (apID)
          (let ([actorFilename (string-append/shared
                                 "actor_"
                                 (number->string (time-second (current-time)))
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
