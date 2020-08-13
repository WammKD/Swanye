;; Migration ADDRESSING_20200812191502 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration ADDRESSING_20200812191502) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'TO
    '(    OBJECT_ID   big-integer (#:not-null))
    '(ADDRESSING_TYPE char-field  (#:not-null #:maxlen 3))
    '(     ACTOR_ID   big-integer (#:not-null))
    #:primary-keys '(OBJECT_ID ADDRESSING_TYPE ACTOR_ID)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'ADDRESSING))
