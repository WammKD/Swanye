;;;; This lib file was generated by GNU Artanis, please add your license header below.
;;;; And please respect the freedom of other people, please.
;;;; <YOUR LICENSE HERE>

(define-module (Swanye database-getters)
  #:use-module (srfi    srfi-1)
  #:use-module (srfi    srfi-9)
  #:use-module (srfi    srfi-19)
  #:use-module (srfi    srfi-26)
  #:use-module (web         uri)
  #:use-module (Swanye    utils)
  #:use-module (artanis   utils)
  #:use-module (artanis    ssql)
  #:use-module (artanis third-party                 json)
  #:use-module (app     models                     USERS)
  #:use-module (app     models                    ACTORS)
  #:use-module (app     models                 ENDPOINTS)
  #:use-module (app     models                ACTIVITIES)
  #:use-module (app     models      ACTIVITIES_BY_ACTORS)
  #:use-module (app     models                    IMAGES)
  #:use-module (app     models                   OBJECTS)
  #:use-module (app     models                  SESSIONS)
  #:use-module (app     models                 TIMELINES)
  #:use-module (app     models                 FOLLOWERS)
  #:export (<activityPub-object>   ap-object?   ap-object-attributed-to ap-object-db-id
                                                ap-object-content       ap-object-ap-id
                                                ap-object-start-time    ap-object-type
                                                ap-object-end-time      ap-object-icons
                                                ap-object-images        ap-object-name
                                                ap-object-published     ap-object-summary
                                                ap-object-url
            get-objects-where
            get-object-dbID-by-apID
            <activityPub-image>    ap-image?    ap-image-db-id         ap-image-ap-id
                                                ap-image-type          ap-image-is-icon?
                                                ap-image-width         ap-image-height
                                                ap-image-attributed-to ap-image-content
                                                ap-image-name          ap-image-start-time
                                                ap-image-end-time      ap-image-icons
                                                ap-image-images        ap-image-published
                                                ap-image-summary       ap-image-url
            get-icons-where
            get-images-where
            <activityPub-post>     ap-post?     ap-post-attributed-to ap-post-db-id
                                                ap-post-content       ap-post-ap-id
                                                ap-post-start-time    ap-post-type
                                                ap-post-end-time      ap-post-icons
                                                ap-post-images        ap-post-name
                                                ap-post-published     ap-post-summary
                                                ap-post-url           ap-post-users-who-have-liked
            get-posts-where
            <activityPub-activity> ap-activity? ap-activity-db-id
                                                ap-activity-ap-id
                                                ap-activity-type
                                                ap-activity-actors
                                                ap-activity-object
                                                ap-activity-name
                                                ap-activity-attributed-to
                                                ap-activity-content
                                                ap-activity-start-time
                                                ap-activity-end-time
                                                ap-activity-icons
                                                ap-activity-images
                                                ap-activity-published
                                                ap-activity-summary
                                                ap-activity-url
            get-activities-where
            <activityPub-actor>    ap-actor?    ap-actor-db-id
                                                ap-actor-ap-id
                                                ap-actor-type
                                                ap-actor-inbox
                                                ap-actor-outbox
                                                ap-actor-following
                                                ap-actor-followers
                                                ap-actor-liked
                                                ap-actor-featured
                                                ap-actor-name
                                                ap-actor-preferred-username
                                                ap-actor-attributed-to
                                                ap-actor-content
                                                ap-actor-start-time
                                                ap-actor-end-time
                                                ap-actor-icons
                                                ap-actor-images
                                                ap-actor-published
                                                ap-actor-summary
                                                ap-actor-url
            get-actors-where
            <swanye-user>          swanye-user? swanye-user-db-id
                                                swanye-user-ap-id
                                                swanye-user-email
                                                swanye-user-password
                                                swanye-user-salt
                                                swanye-user-created-at
                                                swanye-user-confirmation-token
                                                swanye-user-public-key
                                                swanye-user-private-key
                                                swanye-user-type
                                                swanye-user-inbox
                                                swanye-user-outbox
                                                swanye-user-following
                                                swanye-user-followers
                                                swanye-user-liked
                                                swanye-user-featured
                                                swanye-user-name
                                                swanye-user-preferred-username
                                                swanye-user-attributed-to
                                                swanye-user-content
                                                swanye-user-start-time
                                                swanye-user-end-time
                                                swanye-user-icons
                                                swanye-user-images
                                                swanye-user-published
                                                swanye-user-summary
                                                swanye-user-url
            get-users-where
            get-only-user-where
            get-home-timeline
            get-followers-of))

(define-macro (define-record-from-object isUser name . properties)
  (let* ([prefix   (string-append (if (eq? isUser '#t)
                                      "swanye-"
                                    "ap-") (symbol->string name))]
         [preHyph                      (string-append prefix "-")]
         [convert (lambda (str)
                    (string->symbol (string-append preHyph str)))])
    `(define-record-type ,(string->symbol (string-append
                                            "<"
                                            (if (eq? isUser '#t)
                                                "swanye-"
                                              "activityPub-")
                                            (symbol->string name)
                                            ">"))
       (,(string->symbol (string-append "make-" prefix))
         databaseID activityPubID type  ,@(map car properties) attributedTo content name
         startTime  endTime       icons images                 published    summary url)
       ,(string->symbol (string-append prefix "?"))
       (databaseID    ,(convert "db-id")         ,(convert "db-id-set!"))
       (activityPubID ,(convert "ap-id")         ,(convert "ap-id-set!"))
       (type          ,(convert "type")          ,(convert "type-set!"))
       ,@(map
           (lambda (prop)
             (let ([functName (string-append preHyph (symbol->string (cadr prop)))])
               `(,(car prop) ,(string->symbol functName) ,(string->symbol (string-append functName "-set!")))))
           properties)
       (attributedTo  ,(convert "attributed-to") ,(convert "attributed-to-set!"))
       (content       ,(convert "content")       ,(convert "content-set!"))
       (name          ,(convert "name")          ,(convert "name-set!"))
       (startTime     ,(convert "start-time")    ,(convert "start-time-set!"))
       (endTime       ,(convert "end-time")      ,(convert "end-time-set!"))
       (icons         ,(convert "icons")         ,(convert "icons-set!"))
       (images        ,(convert "images")        ,(convert "images-set!"))
       (published     ,(convert "published")     ,(convert "published-set!"))
       (summary       ,(convert "summary")       ,(convert "summary-set!"))
       (url           ,(convert "url")           ,(convert "url-set!")))))

(define-macro (define-record-from-actor isUser name . properties)
  `(define-record-from-object ,isUser ,name
     ,@properties
     [ inbox                         inbox]
     [outbox                        outbox]
     [following                  following]
     [followers                  followers]
     [liked                          liked]
     [featured                    featured]
     [preferredUsername preferred-username]))



(define-macro (create-database-entity-from-object make-funct entity . properties)
  `(create-database-entity ,make-funct ,entity
     ["OBJECT_ID"     identity]
     [    "AP_ID"     identity   (compose string->uri string-reverse)]
     ["OBJECT_TYPE"   identity]
     ,@properties
     ["ATTRIBUTED_TO" positive?  (cut get-actors-where #:ACTOR_ID <> #t)]
     ["CONTENT"       identity]
     ["NAME"          identity]
     ["STARTTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
     [  "ENDTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
     ["ICON"          (const #t) (const (get-icons-where
                                          #:OBJECT_ID (assoc-ref ,entity "OBJECT_ID")))]
     ["IMAGE"         (const #t) (const (get-images-where
                                          #:OBJECT_ID (assoc-ref ,entity "OBJECT_ID")))]
     ["PUBLISHED"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
     ["SUMMARY"       identity]
     ["URL"           identity   (compose string->uri string-reverse)]))

(define-macro (create-database-entity-from-actor make-funct entity . properties)
  `(create-database-entity-from-object ,make-funct ,entity
     ,@properties
     [ "INBOX"             identity              string->uri]
     ["OUTBOX"             identity              string->uri]
     ["FOLLOWING"          (negate string-null?) string->uri]
     ["FOLLOWERS"          (negate string-null?) string->uri]
     ["LIKED"              (negate string-null?) string->uri]
     ["FEATURED"           (negate string-null?) string->uri]
     ["PREFERRED_USERNAME" identity]))

;;;;;;;;;;;;;;;;;;;;;
;;  O B J E C T S  ;;
;;;;;;;;;;;;;;;;;;;;;
(define-record-from-object #f object)

(define (get-objects-where column values)
  (if (null? values)
      '()
    (map
      (lambda (object)
        (create-database-entity-from-object make-ap-object object))
      ($OBJECTS 'get #:columns '(*) #:condition (where column values)))))

(define (get-object-dbID-by-apID activityPubID)
  (define (gather-id obj)
    (define (check-ap-id-and-url apID url)
      (define (convert->string strOrURI)
        (if (uri? strOrURI) (uri->string strOrURI) strOrURI))

      (let ([id (and=> apID convert->string)])
        (if (or (not id) (string-null? id))
            (let ([u (and=> url convert->string)])
              (if (or (not u) (string-null? u))
                  (cons #t 'null)
                (cons #f (string-reverse u))))
          (cons #t (string-reverse id)))))

    (case-pred obj
      [not                                                           (cons #t 'null)]
      [list?       (check-ap-id-and-url  (assoc-ref obj "id") (assoc-ref obj "url"))]
      [string?                                        (cons #t (string-reverse obj))]
      [ap-object?  (check-ap-id-and-url (ap-object-ap-id obj)   (ap-object-url obj))]
      [hash-table? (check-ap-id-and-url  (hash-ref  obj "id") (hash-ref  obj "url"))]))
  (define (filter-for activityPub objects)
    (map cdr (filter (lambda (elem) (eq? activityPub (car elem))) objects)))

  (if-let* ([objs          (map gather-id (if (list? activityPubID)
                                              activityPubID
                                            (list activityPubID)))]
            [possObj null? (let ([apIDs (filter-for #t objs)]
                                 [urls  (filter-for #f objs)])
                             (if (or (not (null? apIDs)) (not (null? urls)))
                                 ($OBJECTS
                                   'get
                                   #:columns   '(OBJECT_ID)
                                   #:condition (where (cond
                                                       [(and
                                                          (not (null? apIDs))
                                                          (not (null?  urls)))
                                                             (/or
                                                               (/or #:AP_ID apIDs)
                                                               (/or #:URL   urls))]
                                                       [(not (null? apIDs))
                                                             (/or #:AP_ID apIDs)]
                                                       [else (/or #:URL   urls)])))
                               '()))])
      #f
    (if (list? activityPubID)
        (map (cut assoc-ref <> "OBJECT_ID") possObj)
      (cdaar possObj))))

;;;;;;;;;;;;;;;;;;;
;;  I M A G E S  ;;
;;;;;;;;;;;;;;;;;;;
(define-record-from-object #f image
  [isIcon is-icon?]
  [width     width]
  [height   height])

(define (get-images-where column values)
  (get-IMAGES-where column values #f))

(define (get-icons-where column values)
  (get-IMAGES-where column values #t))

(define (get-IMAGES-where column values findIcons)
  (define (remove-parent-object-id image)
    (if (assoc-ref image "IMAGE_ID")
        (delete (assoc "OBJECT_ID" image) image)
      image))

  (if (null? values)
      '()
    (let ([isIMAGE (memq column '(#:IMAGE_ID #:WIDTH #:OBJECT_ID #:HEIGHT))])
      (filter
        (lambda (elem)
          (and (((if findIcons identity negate) ap-image-is-icon?) elem) elem))
        (map
          (lambda (dbENTITY)
            (if-let ([otherENTITY null? (map
                                          remove-parent-object-id
                                          ((if isIMAGE $OBJECTS $IMAGES)
                                            'get
                                            #:columns   '(*)
                                            #:condition (where
                                                          (if isIMAGE #:OBJECT_ID #:IMAGE_ID)
                                                          (assoc-ref
                                                            dbENTITY
                                                            (if isIMAGE "IMAGE_ID" "OBJECT_ID")))))])
                #f
              (create-database-entity-from-object make-ap-image (apply append (cons dbENTITY otherENTITY))
                ["IS_ICON"       positive? (const #t)]
                ["WIDTH"         positive?]
                ["HEIGHT"        positive?])))
          (map
            remove-parent-object-id
            ((if isIMAGE $IMAGES $OBJECTS) 'get #:columns   '(*)
                                                #:condition (where column values))))))))

;;;;;;;;;;;;;;;;;
;;  P O S T S  ;;
;;;;;;;;;;;;;;;;;
(define-record-from-object #f post
  [usersWhoHaveLiked users-who-have-liked])

(define (get-posts-where column values)
  (if (null? values)
      '()
    (map
      (lambda (post)
        (let ([actIDs (map
                        (cut assoc-ref <> "ACTIVITY_ID")
                        ($ACTIVITIES
                          'get
                          #:columns   '(*)
                          #:condition (where #:OBJECT_ID (assoc-ref
                                                           post
                                                           "OBJECT_ID"))))])
          (create-database-entity-from-object make-ap-post post
            ["USERS_WHO_HAVE_LIKED" (const #t) (const (apply
                                                        append
                                                        (map
                                                          (cut get-users-where #:USER_ID <>)
                                                          (delete-duplicates
                                                            (map
                                                              (cut assoc-ref <> "ACTOR_ID")
                                                              ($ACTIVITIES_BY_ACTORS
                                                                'get
                                                                #:columns   '(*)
                                                                #:condition (where
                                                                              #:ACTIVITY_ID
                                                                              (map
                                                                                (cut assoc-ref <> "OBJECT_ID")
                                                                                ($OBJECTS
                                                                                  'get
                                                                                  #:columns   '(*)
                                                                                  #:condition (where (/and
                                                                                                       #:OBJECT_TYPE "Like"
                                                                                                       (/or #:OBJECT_ID actIDs))))))))
                                                            =))))])))
      ($OBJECTS 'get #:columns '(*) #:condition (where column values)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  A C T I V I T I E S  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-from-object #f activity
  [actors actors]
  [object object])

(define (get-activities-where column values)
  (if (null? values)
      '()
    (let ([type (cond
                 [(memq column '(#:ACTIVITY_ID #:OBJECT_ID)) 'activity]
                 [(eq?  column                   #:ACTOR_ID)    'actor]
                 [else                                         'object])])
      (filter
        identity
        (map
          (lambda (dbENTITY)
            (if-let ([otherENTITY null? (let ([isACTIVITY (memq type '(activity actor))])
                                          ((if isACTIVITY $OBJECTS $ACTIVITIES)
                                            'get
                                            #:columns   '(*)
                                            #:condition (where
                                                          (if isACTIVITY #:OBJECT_ID #:ACTIVITY_ID)
                                                          (assoc-ref
                                                            dbENTITY
                                                            (if isACTIVITY "ACTIVITY_ID" "OBJECT_ID")))))])
                #f
              (let ([finalENTITY (apply append (cons dbENTITY otherENTITY))])
                (create-database-entity-from-object make-ap-activity finalENTITY
                  [   "ACTOR_ID"   (const #t) (const
                                                (if (eq? type 'actor)
                                                    (get-actors-where #:ACTOR_ID values)
                                                  (get-actors-where
                                                    #:ACTOR_ID
                                                    (map
                                                      (cut assoc-ref <> "ACTOR_ID")
                                                      ($ACTIVITIES_BY_ACTORS
                                                        'get
                                                        #:columns   '(*)
                                                        #:condition (where
                                                                      #:ACTIVITY_ID
                                                                      (assoc-ref
                                                                        finalENTITY
                                                                        "ACTIVITY_ID")))))))]
                  [  "OBJECT_ID"   identity   (compose car (cut get-objects-where #:OBJECT_ID <>))]))))
          (if (eq? type 'actor)
              ($ACTIVITIES
                'get
                #:columns   '(*)
                #:condition (where
                              #:ACTIVITY_ID
                              (map
                                (cut assoc-ref <> "ACTIVITY_ID")
                                ($ACTIVITIES_BY_ACTORS 'get #:columns   '(*)
                                                            #:condition (where column values)))))
            ((if (eq? type 'activity) $ACTIVITIES $OBJECTS)
              'get
              #:columns   '(*)
              #:condition (where column values))))))))

;;;;;;;;;;;;;;;;;;;
;;  A C T O R S  ;;
;;;;;;;;;;;;;;;;;;;
(define-record-from-actor #f actor)

(define* (get-actors-where column values #:optional [returnObjectIfPresent #f])
  (if (null? values)
      '()
    (let ([isACTOR (and
                     (not returnObjectIfPresent)
                     (memq column '(#:ACTOR_ID  #:INBOX #:FOLLOWING #:OUTBOX
                                    #:OBJECT_ID #:LIKED #:FOLLOWERS #:FEATURED #:PREFERRED_USERNAME)))])
      (filter
        identity
        (map
          (lambda (dbENTITY)
            (if-let ([otherENTITY null? ((if isACTOR $OBJECTS $ACTORS)
                                          'get
                                          #:columns   '(*)
                                          #:condition (where
                                                        (if isACTOR #:OBJECT_ID #:ACTOR_ID)
                                                        (assoc-ref
                                                          dbENTITY
                                                          (if isACTOR "ACTOR_ID" "OBJECT_ID"))))])
                (if returnObjectIfPresent dbENTITY #f)
              (create-database-entity-from-actor
                make-ap-actor
                (apply append (cons dbENTITY otherENTITY)))))
          ((if isACTOR $ACTORS $OBJECTS) 'get #:columns   '(*)
                                              #:condition (where
                                                            (cond
                                                             [(and (eq? column #:OBJECT_ID) isACTOR)
                                                                   #:ACTOR_ID]
                                                             [(and (eq? column #:ACTOR_ID)  (not isACTOR))
                                                                   #:OBJECT_ID]
                                                             [else column])
                                                            values)))))))

;;;;;;;;;;;;;;;;;
;;  U S E R S  ;;
;;;;;;;;;;;;;;;;;
(define-record-from-actor #t user
  [email                          email]
  [password                    password]
  [salt                            salt]
  [createdAt                 created-at]
  [confirmationToken confirmation-token]
  [publicKey                 public-key]
  [privateKey               private-key])

(define (get-users-where column values)
  (if (null? values)
      '()
    (let* ([type      (cond
                       [(memq column '(#:USER_ID    #:E_MAIL   
                                       #:ACTOR_ID   #:PASSWORD
                                       #:OBJECT_ID  #:CREATED_AT
                                       #:SALT       #:CONFIRMATION_TOKEN
                                       #:PUBLIC_KEY #:PRIVATE_KEY))
                             'user]
                       [(memq column '(#:INBOX     #:FOLLOWING
                                       #:OUTBOX    #:LIKED
                                       #:FOLLOWERS #:FEATURED #:PREFERRED_USERNAME))
                             'actor]
                       [else 'object])]
           [$ENTITY   (case type
                        [(user)   $USERS]
                        [(actor)  $ACTORS]
                        [(object) $OBJECTS])]
           [ENTITY_ID (case type
                        [(user)   #:USER_ID]
                        [(actor)  #:ACTOR_ID]
                        [(object) #:OBJECT_ID])])
      (filter
        identity
        (map
          (lambda (dbENTITY)
            (if-let* ([remainingIDs                     (delq ENTITY_ID '(#:USER_ID #:ACTOR_ID #:OBJECT_ID))]
                      [remaining$                       (delq $ENTITY        (list $USERS $ACTORS $OBJECTS))]
                      [otherENTITIES (cut any null? <>) (map
                                                          (lambda (E_ID$)
                                                            ((cadr E_ID$)
                                                              'get
                                                              #:columns   '(*)
                                                              #:condition (where
                                                                            (car E_ID$)
                                                                            (assoc-ref
                                                                              dbENTITY
                                                                              (symbol->string
                                                                                (keyword->symbol
                                                                                  ENTITY_ID))))))
                                                          (zip remainingIDs remaining$))])
                #f
              (create-database-entity-from-actor make-swanye-user (apply append (cons dbENTITY (map car otherENTITIES)))
                ["E_MAIL"             identity]
                ["PASSWORD"           identity]
                ["SALT"               identity]
                ["CREATED_AT"         positive? (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["CONFIRMATION_TOKEN" identity]
                [ "PUBLIC_KEY"        identity]
                ["PRIVATE_KEY"        identity])))
          ($ENTITY 'get #:columns   '(*)
                        #:condition (where (if (memq column '(#:OBJECT_ID #:ACTOR_ID))
                                               #:USER_ID
                                             column) values)))))))

(define (get-only-user-where column values)
  (if (null? values)
      '()
    (map
      (lambda (user)
        (create-database-entity make-swanye-user user
          [  "USER_ID"          identity]
          [    "AP_ID"          (const #f)]
          ["OBJECT_TYPE"        (const #f)]
          ["E_MAIL"             identity]
          ["PASSWORD"           identity]
          ["SALT"               identity]
          ["CREATED_AT"         positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
          ["CONFIRMATION_TOKEN" identity]
          [ "PUBLIC_KEY"        identity]
          ["PRIVATE_KEY"        identity]
          [ "INBOX"             (const #f)]
          ["OUTBOX"             (const #f)]
          ["FOLLOWING"          (const #f)]
          ["FOLLOWERS"          (const #f)]
          ["LIKED"              (const #f)]
          ["FEATURED"           (const #f)]
          ["PREFERRED_USERNAME" identity]
          ["ATTRIBUTED_TO"      (const #f)]
          ["CONTENT"            (const #f)]
          ["NAME"               (const #f)]
          ["STARTTIME"          (const #f)]
          [  "ENDTIME"          (const #f)]
          ["ICON"               (const #f)]
          ["IMAGE"              (const #f)]
          ["PUBLISHED"          (const #f)]
          ["SUMMARY"            (const #f)]
          ["URL"                (const #f)]))
      ($USERS 'get #:columns '(*) #:condition (where column values)))))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;  T I M E L I N E S  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-home-timeline sID)
  (apply
    append
    (map
      (compose (cut get-objects-where #:OBJECT_ID <>) cdar)
      ($TIMELINES
        'get
        #:columns   '(OBJECT_ID)
        #:condition (where #:USER_ID (assoc-ref
                                       (car ($SESSIONS
                                              'get
                                              #:columns   '(USER_ID)
                                              #:condition (where #:SESSION_ID sID)))
                                       "USER_ID"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;  F O L L O W E R S  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-followers-of user)
  (let ([userID (case-pred user
                  [swanye-user? (swanye-user-db-id user)]
                  [string?      (swanye-user-db-id
                                  (get-only-user-where #:PREFERRED_USERNAME user))]
                  [number?      user])])
    (get-actors-where
      #:ACTOR_ID
      (map
        (cut assoc-ref <> "ACTOR_ID__FOLLOWER")
        ($FOLLOWERS 'get #:columns   '(*)
                         #:condition (where #:USER_ID__FOLLOWEE userID))))))
