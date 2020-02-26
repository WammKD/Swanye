;; Model FOLLOWERS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  FOLLOWERS
  (ID       big-integer (#:primary-key #:not-null #:unique       #:auto-increment))
  (FOLLOWEE big-integer (#:primary-key #:not-null))
  (FOLLOWER char-field                (#:not-null #:maxlen 20000)))

