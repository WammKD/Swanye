;; Model FOLLOWERS definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  FOLLOWERS
  (ID       auto        (#:primary-key #:not-null #:unique))
  (FOLLOWEE big-integer               (#:not-null))
  (FOLLOWER text                      (#:not-null)))
