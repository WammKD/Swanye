;; Model PEOPLE definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  ACTORS
  (ACTOR_ID           auto        (#:unique))
  (AP_ID              text        (#:not-null))
  (ACTOR_TYPE         char-field  (#:not-null #:maxlen 50))
  ( INBOX             text        (#:not-null))
  (OUTBOX             text        (#:not-null))
  (FOLLOWING          text)
  (FOLLOWERS          text)
  (LIKED              text)
  (FEATURED           text)
  (PREFERRED_USERNAME char-field  (#:not-null #:maxlen 64))
  (NAME               char-field  (#:not-null #:maxlen 64  #:default ""))
  (SUMMARY            char-field  (#:not-null #:maxlen 704 #:default ""))
  (JSON               text        (#:not-null)))
