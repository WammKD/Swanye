;; Model ACTORS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  ACTORS
  (ACTOR_ID           auto       (#:unique))
  ( INBOX             text       (#:not-null))
  (OUTBOX             text       (#:not-null))
  (FOLLOWING          text)
  (FOLLOWERS          text)
  (LIKED              text)
  (FEATURED           text)
  (PREFERRED_USERNAME char-field (#:maxlen 64)))
