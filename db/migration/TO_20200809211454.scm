;; Migration TO_20200809211454 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration TO_20200809211454) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'TO
    '(OBJECT_ID big-integer (#:not-null))
    '( ACTOR_ID big-integer (#:not-null))
    #:primary-keys '(OBJECT_ID ACTOR_ID)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'TO))
