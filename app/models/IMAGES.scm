;; Model FOLLOWERS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  IMAGES
  ( IMAGE_ID big-integer   (#:not-null))
  (OBJECT_ID big-integer   (#:not-null))
  (WIDTH     small-integer)
  (HEIGHT    small-integer)
  (IS_ICON    tiny-integer (#:not-null #:diswidth 1))
  #:primary-keys (IMAGE_ID OBJECT_ID))
