;; Model INBOXES definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  INBOXES
  (    USER_ID big-integer (#:not-null))
  (ACTIVITY_ID big-integer (#:not-null))
  #:primary-keys (USER_ID ACTIVITY_ID))

