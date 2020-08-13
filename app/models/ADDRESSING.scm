;; Model ADDRESSING definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  ADDRESSING
  (    OBJECT_ID   big-integer (#:not-null))
  (ADDRESSING_TYPE char-field  (#:not-null #:maxlen 3))
  (     ACTOR_ID   big-integer (#:not-null))
  #:primary-keys '(OBJECT_ID ADDRESSING_TYPE ACTOR_ID))
