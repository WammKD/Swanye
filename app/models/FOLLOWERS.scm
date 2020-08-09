;; Model FOLLOWERS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  FOLLOWERS
  (PEOPLE_ID__FOLLOWEE big-integer (#:not-null))
  ( ACTOR_ID__FOLLOWER big-integer (#:not-null))
  #:primary-keys (PEOPLE_ID__FOLLOWEE ACTOR_ID__FOLLOWER))

