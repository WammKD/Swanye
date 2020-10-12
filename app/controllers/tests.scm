;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller tests) ; DO NOT REMOVE THIS LINE!!!

(use-modules (rnrs bytevectors) (Swanye database-setters) (app models INBOXES))

(tests-define activity
  (lambda (rc)
    ($INBOXES 'set #:USER_ID     1
                   #:ACTIVITY_ID (insert-activity-auto #t 1 (json-string->scm
                                                              (utf8->string
                                                                (rc-body rc)))))

    (response-emit "OK" #:status 200)))
