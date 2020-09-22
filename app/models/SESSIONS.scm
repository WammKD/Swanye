;; Model SESSIONS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  SESSIONS
  (SESSION_ID char-field  (#:not-null #:maxlen 32))
  (   USER_ID big-integer (#:not-null))
  #:primary-keys (SESSION_ID USER_ID))
