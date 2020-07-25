;; Model FOLLOWERS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  FOLLOWERS
  (ID       auto        (#:unique))
  (FOLLOWEE big-integer (#:not-null))
  (FOLLOWER text        (#:not-null)))

