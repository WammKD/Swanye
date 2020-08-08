;; Migration ACTORS_20200808012536 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration ACTORS_20200808012536) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'ACTORS
    '(ACTOR_ID           auto        (#:unique))
    '(AP_ID              text        (#:not-null))
    '(ACTOR_TYPE         char-field  (#:not-null #:maxlen 50))
    '( INBOX             text        (#:not-null))
    '(OUTBOX             text        (#:not-null))
    '(FOLLOWING          text)
    '(FOLLOWERS          text)
    '(LIKED              text)
    '(FEATURED           text)
    '(NAME               char-field  (#:not-null #:maxlen 64))
    '(PREFERRED_USERNAME char-field  (#:not-null #:maxlen 64  #:default ""))
    '(SUMMARY            char-field  (#:not-null #:maxlen 704 #:default ""))
    '(ENDPOINTS          big-integer)
    '(JSON               text        (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'ACTORS))
