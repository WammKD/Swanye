;; Migration SESSIONS_20200921175148 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration SESSIONS_20200921175148) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'SESSIONS
    '(SESSION_ID char-field  (#:not-null #:maxlen 32))
    '(   USER_ID big-integer (#:not-null))
    #:primary-keys '(SESSION_ID USER_ID)))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'SESSIONS))
