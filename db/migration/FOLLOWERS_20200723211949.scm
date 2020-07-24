;; Migration FOLLOWERS_20200723211949 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWERS_20200723211949) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWERS
    '(ID       auto        (#:primary-key #:not-null #:unique))
    '(FOLLOWEE big-integer (#:primary-key #:not-null))
    '(FOLLOWER text                      (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWERS))
