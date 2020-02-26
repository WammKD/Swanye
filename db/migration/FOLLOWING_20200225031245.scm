;; Migration FOLLOWING_20200225031245 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWING_20200225031245) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWING
    '(ID       big-integer (#:not-null     #:unique       #:auto-increment))
    '(FOLLOWER big-integer (#:not-null))
    '(FOLLOWEE char-field  (#:not-null     #:maxlen 20000))
    '(PENDING  char-field  (#:default NULL #:maxlen 0))
    #:primary-keys '(ID FOLLOWER)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWING))
