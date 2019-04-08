;; Migration FOLLOWERS_20190406201020 definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWERS_20190406201020) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWERS
    '(FOLLOWEE big-integer (#:primary-key #:not-null))
    '(FOLLOWER char-field  (#:primary-key #:not-null #:maxlen 60000))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWERS))
