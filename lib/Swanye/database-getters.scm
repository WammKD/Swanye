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
                                                ap-object-end-time      ap-object-icon
                                                ap-object-image         ap-object-name
                                                ap-object-published     ap-object-summary
                                                ap-object-url
            get-objects-where
            get-object-dbID-by-apID
            <activityPub-image>    ap-image?    ap-image-db-id         ap-image-ap-id
                                                ap-image-type          ap-image-is-icon?
                                                ap-image-width         ap-image-height
                                                ap-image-attributed-to ap-image-content
                                                ap-image-name          ap-image-start-time
                                                ap-image-end-time      ap-image-icon
                                                ap-image-image         ap-image-published
                                                ap-image-summary       ap-image-url
            get-icons-where
            get-images-where
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
                                                swanye-user-published
                                                swanye-user-summary
                                                swanye-user-url
            get-users-where
            get-only-user-where
            get-home-timeline
            get-followers-of))

;;;;;;;;;;;;;;;;;;;;;
;;  O B J E C T S  ;;
;;;;;;;;;;;;;;;;;;;;;
(define-record-type <activityPub-object>
  (make-ap-object databaseID activityPubID type attributedTo content   name
                  startTime  endTime       icon image        published summary url)
  ap-object?
  (databaseID    ap-object-db-id         ap-object-db-id-set!)
  (activityPubID ap-object-ap-id         ap-object-ap-id-set!)
  (type          ap-object-type          ap-object-type-set!)
  (attributedTo  ap-object-attributed-to ap-object-attributed-to-set!)
  (content       ap-object-content       ap-object-content-set!)
  (name          ap-object-name          ap-object-name-set!)
  (startTime     ap-object-start-time    ap-object-start-time-set!)
  (endTime       ap-object-end-time      ap-object-end-time-set!)
  (icon          ap-object-icon          ap-object-icon-set!)
  (image         ap-object-image         ap-object-image-set!)
  (published     ap-object-published     ap-object-published-set!)
  (summary       ap-object-summary       ap-object-summary-set!)
  (url           ap-object-url           ap-object-url-set!))

(define (get-objects-where column values)
  (if (null? values)
      '()
    (map
      (lambda (object)
        (create-database-entity make-ap-object object
          ["OBJECT_ID"     identity]
          [    "AP_ID"     identity   (compose string->uri string-reverse)]
          ["OBJECT_TYPE"   identity]
          ["ATTRIBUTED_TO" positive?  (cut get-actors-where #:ACTOR_ID <> #t)]
          ["CONTENT"       identity]
          ["NAME"          identity]
          ["STARTTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
          [  "ENDTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
          ["ICON"          (const #t) (const (get-icons-where
                                               #:OBJECT_ID (assoc-ref object "OBJECT_ID")))]
          ["IMAGE"         (const #t) (const (get-images-where
                                               #:OBJECT_ID (assoc-ref object "OBJECT_ID")))]
          ["PUBLISHED"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
          ["SUMMARY"       identity]
          ["URL"           identity   (compose string->uri string-reverse)]))
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
(define-record-type <activityPub-image>
  (make-ap-image databaseID activityPubID type    isIcon    width
                 height     attributedTo  content name      startTime
                 endTime    icon          image   published summary   url)
  ap-image?
  (databaseID    ap-image-db-id         ap-image-db-id-set!)
  (activityPubID ap-image-ap-id         ap-image-ap-id-set!)
  (type          ap-image-type          ap-image-type-set!)
  (isIcon        ap-image-is-icon?      ap-image-is-icon-set!)
  (width         ap-image-width         ap-image-width-set!)
  (height        ap-image-height        ap-image-height-set!)
  (attributedTo  ap-image-attributed-to ap-image-attributed-to-set!)
  (content       ap-image-content       ap-image-content-set!)
  (name          ap-image-name          ap-image-name-set!)
  (startTime     ap-image-start-time    ap-image-start-time-set!)
  (endTime       ap-image-end-time      ap-image-end-time-set!)
  (icon          ap-image-icon          ap-image-icon-set!)
  (image         ap-image-image         ap-image-image-set!)
  (published     ap-image-published     ap-image-published-set!)
  (summary       ap-image-summary       ap-image-summary-set!)
  (url           ap-image-url           ap-image-url-set!))

(define (get-images-where column values)
  (get-IMAGES-where column values #f))

(define (get-icons-where column values)
  (get-IMAGES-where column values #t))

(define (get-IMAGES-where column values findIcons)
  (if (null? values)
      '()
    (let ([isIMAGE (memq column '(#:IMAGE_ID #:WIDTH #:OBJECT_ID #:HEIGHT))])
      (filter
        (lambda (elem)
          (and (((if findIcons identity negate) ap-image-is-icon?) elem) elem))
        (map
          (lambda (dbENTITY)
            (if-let ([otherENTITY null? ((if isIMAGE $OBJECTS $IMAGES)
                                          'get
                                          #:columns   '(*)
                                          #:condition (where
                                                        (if isIMAGE #:OBJECT_ID #:IMAGE_ID)
                                                        (assoc-ref
                                                          dbENTITY
                                                          (if isIMAGE "IMAGE_ID" "OBJECT_ID"))))])
                #f
              (create-database-entity make-ap-image (apply append (cons dbENTITY otherENTITY))
                ["OBJECT_ID"     identity]
                [    "AP_ID"     identity   (compose string->uri string-reverse)]
                ["OBJECT_TYPE"   identity]
                ["IS_ICON"       identity]
                ["WIDTH"         identity]
                ["HEIGHT"        identity]
                ["ATTRIBUTED_TO" positive?  (cut get-actors-where #:ACTOR_ID <> #t)]
                ["CONTENT"       identity]
                ["NAME"          identity]
                ["STARTTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
                [  "ENDTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["ICON"          (const #t) (const (get-icons-where
                                                     #:OBJECT_ID (assoc-ref
                                                                   (apply append (cons
                                                                                      dbENTITY
                                                                                   otherENTITY))
                                                                   "OBJECT_ID")))]
                ["IMAGE"         (const #t) (const (get-images-where
                                                     #:OBJECT_ID (assoc-ref
                                                                   (apply append (cons
                                                                                      dbENTITY
                                                                                   otherENTITY))
                                                                   "OBJECT_ID")))]
                ["PUBLISHED"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["SUMMARY"       identity]
                ["URL"           identity   (compose string->uri string-reverse)])))
          ((if isIMAGE $IMAGES $OBJECTS) 'get #:columns   '(*)
                                              #:condition (where column values)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  A C T I V I T I E S  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <activityPub-activity>
  (make-ap-activity databaseID   activityPubID type      actors  object    name
                    attributedTo content       startTime endTime published summary url)
  ap-activity?
  (databaseID    ap-activity-db-id         ap-activity-db-id-set!)
  (activityPubID ap-activity-ap-id         ap-activity-ap-id-set!)
  (type          ap-activity-type          ap-activity-type-set!)
  (actors        ap-activity-actors        ap-activity-actors-set!)
  (object        ap-activity-object        ap-activity-object-set!)
  (name          ap-activity-name          ap-activity-name-set!)
  (attributedTo  ap-activity-attributed-to ap-activity-attributed-to-set!)
  (content       ap-activity-content       ap-activity-content-set!)
  (startTime     ap-activity-start-time    ap-activity-start-time-set!)
  (endTime       ap-activity-end-time      ap-activity-end-time-set!)
  (published     ap-activity-published     ap-activity-published-set!)
  (summary       ap-activity-summary       ap-activity-summary-set!)
  (url           ap-activity-url           ap-activity-url-set!))

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
                (create-database-entity make-ap-activity finalENTITY
                  ["ACTIVITY_ID"   identity]
                  [      "AP_ID"   identity   (compose string->uri string-reverse)]
                  [  "OBJECT_TYPE" identity]
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
                  [  "OBJECT_ID"   identity   (compose car (cut get-objects-where #:OBJECT_ID <>))]
                  ["NAME"          identity]
                  ["ATTRIBUTED_TO" positive?  (cut get-actors-where #:ACTOR_ID <> #t)]
                  ["CONTENT"       identity]
                  ["STARTTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
                  [  "ENDTIME"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
                  ["PUBLISHED"     positive?  (compose time-utc->date (cut make-time time-utc 0 <>))]
                  ["SUMMARY"       identity]
                  ["URL"           identity   (compose string->uri string-reverse)]))))
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
(define-record-type <activityPub-actor>
  (make-ap-actor databaseID activityPubID type              inbox
                 outbox     following     followers         liked
                 featured   name          preferredUsername attributedTo
                 content    startTime     endTime           published    summary url)
  ap-actor?
  (databaseID        ap-actor-db-id              ap-actor-db-id-set!)
  (activityPubID     ap-actor-ap-id              ap-actor-ap-id-set!)
  (type              ap-actor-type               ap-actor-type-set!)
  (inbox             ap-actor-inbox              ap-actor-inbox-set!)
  (outbox            ap-actor-outbox             ap-actor-outbox-set!)
  (following         ap-actor-following          ap-actor-following-set!)
  (followers         ap-actor-followers          ap-actor-followers-set!)
  (liked             ap-actor-liked              ap-actor-liked-set!)
  (featured          ap-actor-featured           ap-actor-featured-set!)
  (name              ap-actor-name               ap-actor-name-set!)
  (preferredUsername ap-actor-preferred-username ap-actor-preferred-username-set!)
  (attributedTo      ap-actor-attributed-to      ap-actor-attributed-to-set!)
  (content           ap-actor-content            ap-actor-content-set!)
  (startTime         ap-actor-start-time         ap-actor-start-time-set!)
  (endTime           ap-actor-end-time           ap-actor-end-time-set!)
  (published         ap-actor-published          ap-actor-published-set!)
  (summary           ap-actor-summary            ap-actor-summary-set!)
  (url               ap-actor-url                ap-actor-url-set!))

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
              (create-database-entity make-ap-actor (apply append (cons dbENTITY otherENTITY))
                ["OBJECT_ID"          identity]
                [    "AP_ID"          identity              (compose string->uri string-reverse)]
                ["OBJECT_TYPE"        identity]
                [ "INBOX"             identity              string->uri]
                ["OUTBOX"             identity              string->uri]
                ["FOLLOWING"          (negate string-null?) string->uri]
                ["FOLLOWERS"          (negate string-null?) string->uri]
                ["LIKED"              (negate string-null?) string->uri]
                ["FEATURED"           (negate string-null?) string->uri]
                ["NAME"               identity]
                ["PREFERRED_USERNAME" identity]
                ["ATTRIBUTED_TO"      positive?             (cut get-actors-where #:ACTOR_ID <> #t)]
                ["CONTENT"            identity]
                ["STARTTIME"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                [  "ENDTIME"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["PUBLISHED"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["SUMMARY"            identity]
                ["URL"                identity              (compose string->uri string-reverse)])))
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
(define-record-type <swanye-user>
  (make-swanye-user databaseID activityPubID     type         email
                    password   salt              createdAt    confirmationToken
                    publicKey  privateKey        inbox        outbox
                    following  followers         liked        featured
                    name       preferredUsername attributedTo content
                    startTime  endTime           published    summary           url)
  swanye-user?
  (databaseID        swanye-user-db-id              swanye-user-db-id-set!)
  (activityPubID     swanye-user-ap-id              swanye-user-ap-id-set!)
  (email             swanye-user-email              swanye-user-email-set!)
  (password          swanye-user-password           swanye-user-password-set!)
  (salt              swanye-user-salt               swanye-user-salt-set!)
  (createdAt         swanye-user-created-at         swanye-user-created-at-set!)
  (confirmationToken swanye-user-confirmation-token swanye-user-confirmation-token-set!)
  (publicKey         swanye-user-public-key         swanye-user-public-key-set!)
  (privateKey        swanye-user-private-key        swanye-user-private-key-set!)
  (type              swanye-user-type               swanye-user-type-set!)
  (inbox             swanye-user-inbox              swanye-user-inbox-set!)
  (outbox            swanye-user-outbox             swanye-user-outbox-set!)
  (following         swanye-user-following          swanye-user-following-set!)
  (followers         swanye-user-followers          swanye-user-followers-set!)
  (liked             swanye-user-liked              swanye-user-liked-set!)
  (featured          swanye-user-featured           swanye-user-featured-set!)
  (name              swanye-user-name               swanye-user-name-set!)
  (preferredUsername swanye-user-preferred-username swanye-user-preferred-username-set!)
  (attributedTo      swanye-user-attributed-to      swanye-user-attributed-to-set!)
  (content           swanye-user-content            swanye-user-content-set!)
  (startTime         swanye-user-start-time         swanye-user-start-time-set!)
  (endTime           swanye-user-end-time           swanye-user-end-time-set!)
  (published         swanye-user-published          swanye-user-published-set!)
  (summary           swanye-user-summary            swanye-user-summary-set!)
  (url               swanye-user-url                swanye-user-url-set!))

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
              (create-database-entity make-swanye-user (apply append (cons dbENTITY (map car otherENTITIES)))
                ["OBJECT_ID"          identity]
                [    "AP_ID"          identity              (compose string->uri string-reverse)]
                ["OBJECT_TYPE"        identity]
                ["E_MAIL"             identity]
                ["PASSWORD"           identity]
                ["SALT"               identity]
                ["CREATED_AT"         positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["CONFIRMATION_TOKEN" identity]
                [ "PUBLIC_KEY"        identity]
                ["PRIVATE_KEY"        identity]
                [ "INBOX"             identity              string->uri]
                ["OUTBOX"             identity              string->uri]
                ["FOLLOWING"          (negate string-null?) string->uri]
                ["FOLLOWERS"          (negate string-null?) string->uri]
                ["LIKED"              (negate string-null?) string->uri]
                ["FEATURED"           (negate string-null?) string->uri]
                ["NAME"               identity]
                ["PREFERRED_USERNAME" identity]
                ["ATTRIBUTED_TO"      positive?             (cut get-actors-where #:ACTOR_ID <> #t)]
                ["CONTENT"            identity]
                ["STARTTIME"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                [  "ENDTIME"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["PUBLISHED"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
                ["SUMMARY"            identity]
                ["URL"                identity              (compose string->uri string-reverse)])))
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
          [    "AP_ID"          identity              (compose string->uri string-reverse)]
          ["OBJECT_TYPE"        identity]
          ["E_MAIL"             identity]
          ["PASSWORD"           identity]
          ["SALT"               identity]
          ["CREATED_AT"         positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
          ["CONFIRMATION_TOKEN" identity]
          [ "PUBLIC_KEY"        identity]
          ["PRIVATE_KEY"        identity]
          [ "INBOX"             identity              string->uri]
          ["OUTBOX"             identity              string->uri]
          ["FOLLOWING"          (negate string-null?) string->uri]
          ["FOLLOWERS"          (negate string-null?) string->uri]
          ["LIKED"              (negate string-null?) string->uri]
          ["FEATURED"           (negate string-null?) string->uri]
          ["NAME"               identity]
          ["PREFERRED_USERNAME" identity]
          ["ATTRIBUTED_TO"      positive?             (cut get-actors-where #:ACTOR_ID <> #t)]
          ["CONTENT"            identity]
          ["STARTTIME"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
          [  "ENDTIME"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
          ["PUBLISHED"          positive?             (compose time-utc->date (cut make-time time-utc 0 <>))]
          ["SUMMARY"            identity]
          ["URL"                identity              (compose string->uri string-reverse)]))
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
