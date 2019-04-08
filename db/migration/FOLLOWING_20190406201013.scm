;; Migration FOLLOWING_20190406201013 definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWING_20190406201013) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWING
    '(FOLLOWER big-integer (#:primary-key #:not-null))
    '(FOLLOWEE char-field  (#:primary-key #:not-null #:maxlen 60000))
    '(PENDING  boolean                   (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWING))
