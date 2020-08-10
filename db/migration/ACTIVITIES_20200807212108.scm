;; Migration ACTIVITIES_20200807212108 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration ACTIVITIES_20200807212108) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'ACTIVITIES
    '(ACTIVITY_ID   auto        (#:unique))
    '(      AP_ID   text        (#:not-null))
    '(ACTIVITY_TYPE char-field  (#:not-null #:maxlen 50))
    '(   ACTOR_ID   big-integer (#:not-null))
    '(  OBJECT_ID   big-integer (#:not-null))
    '(JSON          text        (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'ACTIVITIES))
