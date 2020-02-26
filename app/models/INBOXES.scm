;; Model INBOXES definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  INBOXES
  (ID        auto        (#:primary-key  #:not-null #:unique))
  (PERSON_ID big-integer                (#:not-null))
  (ACTIVITY  text                       (#:not-null))
  (TYPE      text                       (#:not-null)))

