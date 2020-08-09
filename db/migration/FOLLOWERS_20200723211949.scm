;; Migration FOLLOWERS_20200723211949 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWERS_20200723211949) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWERS
    '( USER_ID__FOLLOWEE big-integer (#:not-null))
    '(ACTOR_ID__FOLLOWER big-integer (#:not-null))
    #:primary-keys '(USER_ID__FOLLOWEE ACTOR_ID__FOLLOWER)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWERS))
