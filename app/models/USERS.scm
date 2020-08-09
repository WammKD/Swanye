;; Model USERS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  USERS
  (USER_ID            auto        (#:primary-key  #:not-null #:unique))
  (ACTOR_ID           big-integer                (#:not-null #:unique))
  (USERNAME           char-field  (#:maxlen    64 #:not-null #:unique))
  (E_MAIL             char-field  (#:maxlen   255 #:not-null))
  (PASSWORD           char-field  (#:maxlen   128 #:not-null))
  (SALT               char-field  (#:maxlen   256 #:not-null))
  (CREATED_AT         big-integer                (#:not-null))
  (CONFIRMATION_TOKEN char-field  (#:maxlen   128 #:not-null))
  ( PUBLIC_KEY        text                       (#:not-null))
  (PRIVATE_KEY        text                       (#:not-null)))

