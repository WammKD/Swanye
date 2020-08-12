;; Model OBJECTS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  OBJECTS
  (OBJECT_ID   auto       (#:unique))
  (    AP_ID   text       (#:not-null))
  (OBJECT_TYPE char-field (#:not-null #:maxlen 50))
  (JSON        text       (#:not-null)))
