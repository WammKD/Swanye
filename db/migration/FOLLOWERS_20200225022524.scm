;; Migration followers_20200225022524 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWERS_20200225022524) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWERS
    '(FOLLOWEE big-integer (#:not-null))
    '(FOLLOWER char-field  (#:not-null #:maxlen 32))
    #:primary-keys '(FOLLOWEE FOLLOWER)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWERS))
