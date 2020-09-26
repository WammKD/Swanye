;; Model OBJECTS definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-model   ; DO NOT REMOVE THIS LINE!!!
  OBJECTS
  (OBJECT_ID     auto        (#:unique))
  (    AP_ID     text        (#:not-null))
  (OBJECT_TYPE   char-field  (#:not-null #:maxlen 50))
  ;;;; These can be a single or many relation
  ;;;; I'll probably want to handle these with a linking table
  ;; (ATTACHMENT    big-integer)
  ;; (ATTRIBUTED_TO )
  ;; (AUDIENCE      )
  (CONTENT       text)
  ;;;; The spec. says this is intentionally vague but that reads
  ;;;; as "undefined", to me; we may leave this guy out until we
  ;;;; determine if it's even needed
  ;; (CONTEXT       )
  (NAME          char-field  (#:maxlen 64))
  (STARTTIME     date-field)
  (  ENDTIME     date-field)
  ;;;; Also vague; seems it stores any kind of object so we'll put
  ;;;; an ID, here; we'll also not bother with it, for now
  ;; (GENERATOR     big-integer)
  ;;;; This one, at least, is specific but it can also have a list
  ;;;; of values and I don't want to build this, yet
  ;; (ICON          )
  ;;;; Honestly, content was the main thing I wanted so I'm just
  ;;;; going to add the rest of the possible properties here and
  ;;;; implement them later
  ;; (IMAGE            )
  ;; (IN_REPLY_TO      )
  ;; (LOCATION         )
  ;; (PREVIEW          )
  ;; (PUBLISHED        )
  ;; (REPLIES          )
  ;; (SUMMARY          )
  ;; (TAG              )
  ;; (UPDATED          )
  ;; (URL              )
  ;; (MEDIA_TYPE       )
  ;; (DURATION         )
  (JSON          text        (#:not-null)))
