;; Migration FOLLOWING_20200723212808 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWING_20200723212808) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWING
    '( USER_ID__FOLLOWER big-integer  (#:not-null))
    '(ACTOR_ID__FOLLOWEE big-integer  (#:not-null))
    '(PENDING   tiny-integer (#:not-null))
    #:primary-keys '(USER_ID__FOLLOWER ACTOR_ID__FOLLOWEE)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWING))
