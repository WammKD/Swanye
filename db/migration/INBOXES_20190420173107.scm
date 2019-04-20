;; Migration INBOXES_20190420173107 definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration INBOXES_20190420173107) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'INBOXES
    '(ID        auto        (#:primary-key  #:not-null #:unique))
    '(PERSON_ID big-integer                (#:not-null))
    '(ACTIVITY  text                       (#:not-null))
    '(TYPE      text                       (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWERS))
