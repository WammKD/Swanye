;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller main) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app models    ACTORS) (srfi            srfi-19)
             (app models   OBJECTS) (srfi            srfi-26)
             (app models  SESSIONS) (Swanye database-getters)
             (app models TIMELINES) (Swanye            utils))

(get "/" #:with-auth "/auth/sign_in"
  (lambda (rc)
    (process-redirect rc "/main/home")))

(main-define home
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (let ([posts (get-home-timeline (car (assoc-ref
                                           (map
                                             (cut string-split <> #\=)
                                             (string-split
                                               (assoc-ref
                                                 (request-headers (rc-req rc))
                                                 'cookie)
                                               #\,))
                                           "sid")))])
      (view-render "main" (the-environment)))))
