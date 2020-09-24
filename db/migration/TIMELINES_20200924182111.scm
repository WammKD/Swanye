;; Migration TIMELINES_20200924182111 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration TIMELINES_20200924182111) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'TIMELINES
    '(TIMELINE_ORDERING_ID auto        (#:unique))
    '(             USER_ID big-integer (#:not-null))
    '(           OBJECT_ID big-integer (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'TIMELINES))
