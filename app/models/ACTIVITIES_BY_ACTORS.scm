;; Model FOLLOWERS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  ACTIVITIES_BY_ACTORS
  (ACTIVITY_ID big-integer (#:not-null))
  (   ACTOR_ID big-integer (#:not-null))
  #:primary-keys (ACTIVITY_ID ACTOR_ID))
