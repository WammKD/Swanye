;; Migration FOLLOWING_20200723212808 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration FOLLOWING_20200723212808) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'FOLLOWING
    '(ID       auto        (#:unique))
    '(FOLLOWER big-integer (#:not-null))
    '(FOLLOWEE text        (#:not-null))
    '(PENDING  boolean     (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'FOLLOWING))
