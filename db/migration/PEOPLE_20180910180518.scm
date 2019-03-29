;; Migration PEOPLE_20180910180518 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration PEOPLE_20180910180518) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'PEOPLE
    '(ID                 auto        (#:primary-key  #:not-null #:unique))
    '(USERNAME           char-field  (#:maxlen    32 #:not-null #:unique))
    '(E_MAIL             char-field  (#:maxlen   256 #:not-null))
    '(PASSWORD           char-field  (#:maxlen   500 #:not-null))
    '(SALT               char-field  (#:maxlen   256 #:not-null))
    '(NAME               char-field  (#:maxlen    32 #:not-null #:default ""))
    '(SUMMARY            char-field  (#:maxlen   500 #:not-null #:default ""))
    '(CREATED_AT         big-integer                (#:not-null))
    '(CONFIRMATION_TOKEN char-field  (#:maxlen   128 #:not-null))
    '(PUBLIC             char-field  (#:maxlen 10000 #:not-null))
    '(PRIVATE            char-field  (#:maxlen 10000 #:not-null))))
(migrate-up
  (change-table
    'PEOPLE
    '((NAME     "test")
      (PASSWORD "cd56f562179949664713674d99f59ebf52810e4c655465a2fb01be20d5218d7712f2039db3cfdd2e8249cb876ced52b426b201f577181e455e4cd461057b8365")
      (SALT     "8071f9e536662df8f58de2342158398b33b54cc07298b9f01bd19eb63c5668f198a54d5586a94ac711ffad7cd14a09cc0cb0186c702a2effddc287bbf08ec1b660a28789d9fd60e3e70ac31fcba6bf415427ac6b5045912d1f6ad04694d236f53af7f81daa9a8700056b58b218a53d4207a4f3089e4766ed8231f0556515b16c"))))
(migrate-down
  (drop-table 'PEOPLE))
