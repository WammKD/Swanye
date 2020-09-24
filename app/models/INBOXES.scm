;; Model INBOXES definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  INBOXES
  (       ID     auto        (#:unique))
  (  USER_ID     big-integer (#:not-null))
  ( ACTOR_ID     big-integer (#:not-null))
  (OBJECT_ID     big-integer (#:not-null))
  (ACTIVITY      text        (#:not-null))
  (ACTIVITY_TYPE text        (#:not-null)))

