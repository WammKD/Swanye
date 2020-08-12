;; Migration OBJECTS_20200807212115 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration OBJECTS_20200807212115) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'OBJECTS
    '(OBJECT_ID   auto       (#:unique))
    '(    AP_ID   text       (#:not-null))
    '(OBJECT_TYPE char-field (#:not-null #:maxlen 50))
    '(JSON        text       (#:not-null))))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'OBJECTS))
