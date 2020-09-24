;; Model INBOXES definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  TIMELINES
  (TIMELINE_ORDERING_ID auto        (#:unique))
  (             USER_ID big-integer (#:not-null))
  (           OBJECT_ID big-integer (#:not-null)))
