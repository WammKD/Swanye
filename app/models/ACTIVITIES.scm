;; Model ACTIVITIES definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  ACTIVITIES
  (ACTIVITY_ID   auto        (#:unique))
  (      AP_ID   text        (#:not-null))
  (ACTIVITY_TYPE char-field  (#:not-null #:maxlen 50))
  (   ACTOR_ID   big-integer (#:not-null))
  (  OBJECT_ID   big-integer (#:not-null))
  (JSON          text        (#:not-null)))
