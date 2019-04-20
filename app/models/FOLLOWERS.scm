;; Model FOLLOWERS definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  FOLLOWERS
  (FOLLOWEE big-integer (#:not-null))
  (FOLLOWER char-field  (#:not-null #:maxlen 3008))
  #:primary-keys (FOLLOWEE FOLLOWER))
