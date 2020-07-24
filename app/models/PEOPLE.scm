;; Model PEOPLE definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model PEOPLE   ; DO NOT REMOVE THIS LINE!!!
  PEOPLE
  (ID                 auto        (#:primary-key  #:not-null #:unique))
  (USERNAME           char-field  (#:maxlen    32 #:not-null #:unique))
  (E_MAIL             char-field  (#:maxlen   255 #:not-null))
  (PASSWORD           char-field  (#:maxlen   500 #:not-null))
  (SALT               char-field  (#:maxlen   255 #:not-null))
  (NAME               char-field  (#:maxlen    32 #:not-null #:default ""))
  (SUMMARY            char-field  (#:maxlen   500 #:not-null #:default ""))
  (CREATED_AT         big-integer                (#:not-null))
  (CONFIRMATION_TOKEN char-field  (#:maxlen   128 #:not-null))
  (PUBLIC             text                       (#:not-null))
  (PRIVATE            text                       (#:not-null)))

