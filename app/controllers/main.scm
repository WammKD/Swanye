;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller main) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models    ACTORS) (srfi srfi-26)
             (app models   OBJECTS) (Swanye utils)
             (app models  SESSIONS)
             (app models TIMELINES))

(get "/" #:with-auth "/auth/sign_in"
  (lambda (rc)
    (process-redirect rc "/main/home")))

(main-define home
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (let ([postsAndCreator (map
                             (lambda (post)
                               (let ([ACTOR_ID (assoc-ref post "ATTRIBUTED_TO")])
                                 (cons
                                   post
                                   (append
                                     (car ($OBJECTS
                                            'get
                                            #:columns   '(*)
                                            #:condition (where #:OBJECT_ID ACTOR_ID)))
                                     (car ($ACTORS
                                            'get
                                            #:columns   '(*)
                                            #:condition (where #:ACTOR_ID  ACTOR_ID)))))))
                             ($OBJECTS
                               'get
                               #:columns   '(*)
                               #:condition (where
                                             #:OBJECT_ID
                                             (map cdar ($TIMELINES
                                                         'get
                                                         #:columns   '(OBJECT_ID)
                                                         #:condition (where
                                                                       #:USER_ID
                                                                       (assoc-ref
                                                                         (car ($SESSIONS
                                                                                'get
                                                                                #:columns   '(USER_ID)
                                                                                #:condition (where
                                                                                              #:SESSION_ID
                                                                                              (car (assoc-ref
                                                                                                     (map
                                                                                                       (cut string-split <> #\=)
                                                                                                       (string-split
                                                                                                         (assoc-ref
                                                                                                           (request-headers
                                                                                                             (rc-req rc))
                                                                                                           'cookie)
                                                                                                         #\,))
                                                                                                     "sid")))))
                                                                         "USER_ID")))))))])
      (view-render "main" (the-environment)))))
