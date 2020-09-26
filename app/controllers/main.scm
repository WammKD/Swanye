;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller main) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models   OBJECTS) (srfi srfi-26)
             (app models  SESSIONS) (Swanye utils)
             (app models TIMELINES))

(get "/" #:with-auth "/auth/sign_in"
  (lambda (rc)
    (process-redirect rc "/main/home")))

(main-define home
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (let ([posts ($OBJECTS
                   'get
                   #:columns   '(*)
                   #:condition (where
                                 #:OBJECT_ID
                                 (assoc-ref
                                   (car ($TIMELINES
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
                                                                                            (request-headers (rc-req rc))
                                                                                            'cookie)
                                                                                          #\,))
                                                                                      "sid")))))
                                                          "USER_ID"))))
                                   "OBJECT_ID")))])
      (view-render "main" (the-environment)))))
