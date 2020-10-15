;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller frontend-handling) ; DO NOT REMOVE THIS LINE!!!

(use-modules (app       models  OBJECTS) (ice-9        hash-table)
             (app       models SESSIONS) (srfi            srfi-19)
             (industria crypto blowfish) (srfi            srfi-26)
                                         (srfi            srfi-98)
                                         (Swanye database-getters)
                                         (Swanye database-setters)
                                         (Swanye            utils)
                                         (web                 uri))

(post "/frontend/like" #:session #t #:from-post 'qstr-safe
  (lambda (rc)
    (if (:session rc 'check)
        (let* ([user             (car (get-users-where
                                        #:USER_ID
                                        (assoc-ref
                                          (car ($SESSIONS
                                                 'get
                                                 #:columns   '(USER_ID)
                                                 #:condition (where
                                                               #:SESSION_ID
                                                               (car (assoc-ref
                                                                      (map
                                                                        (cut string-split <> #\=)
                                                                        (string-split
                                                                          (assoc-ref
                                                                            (request-headers
                                                                              (rc-req rc))
                                                                            'cookie)
                                                                          #\,))
                                                                      "sid")))))
                                          "USER_ID")))]
               [username                 (swanye-user-preferred-username user)]
               [currentTime      (number->string (time-second (current-time)))]
               [currentDate      (date->string
                                   (current-date)
                                   "~a, ~d ~b ~Y ~3 GMT")]
               [actorInbox          (uri-decode (:from-post rc 'get "inbox"))]
               [privateEncrypted (eval-string (swanye-user-private-key user))]
               [baseFilename     (string-append/shared "/tmp/siB64_" username
                                                       currentTime    ".txt")]
               [ sigFilename     (string-append/shared "/tmp/signa_" username
                                                       currentTime    ".txt")]
               [privFilename     (string-append/shared "/tmp/priva_" username
                                                       currentTime    ".txt")]
               [ sigPort                         (open-file  sigFilename "w")]
               [privPort                         (open-file privFilename "w")]
               [stringToSign      (let ([uri (string->uri actorInbox)])
                                    (string-append/shared
                                      "(request-target): post " (uri-path uri)
                                      "\nhost: "                (uri-host uri)
                                      "\ndate: "                currentDate))]
               [objectActPubID   (uri-decode (:from-post rc 'get "objectID"))]
               [scmJSON          (alist->hash-table
                                   `(("@context" . "https://www.w3.org/ns/activitystreams")
                                     ("id"       . ,(string-append
                                                      "https://temp/"
                                                      (number->string (swanye-user-db-id user))
                                                      "/"
                                                      (substring objectActPubID 8)))
                                     ("type"     . "Like")
                                     ("actor"    . ,(uri->string (swanye-user-ap-id user)))
                                     ("object"   . ,objectActPubID)))]
               [activityID       (insert-activity-auto
                                   #t
                                   (swanye-user-db-id user)
                                   scmJSON)]
               [activityActPubID (string-append
                                   (uri->string (swanye-user-ap-id user))
                                   "/liked/"
                                   (number->string activityID))])
          ($OBJECTS
            'set
            #:AP_ID (string-reverse activityActPubID)
            (where #:OBJECT_ID activityID))
          (hash-set! scmJSON "id" activityActPubID)

          (blowfish-decrypt!
            privateEncrypted 0
            privateEncrypted 0
            (reverse-blowfish-schedule
              (eval-string (get-environment-variable "BLOWFISH_SCHEDULE"))))

          (display (utf8->string privateEncrypted) privPort)
          (close privPort)

          (display stringToSign sigPort)
          (close sigPort)

          (system (string-append/shared "openssl dgst -sha256 -sign "  privFilename
                                        " " sigFilename " | base64 > " baseFilename))
          (system (string-append/shared "rm " privFilename " " sigFilename))

          (display "\n\n\n\nFUCKERSHIT\n\n\n\n")
          (display (string-append/shared
                     "curl -H \"Content-Type: application/json\" "
                          "-H \"Host: "    (uri-host (string->uri actorInbox)) "\" "
                          "-H \"Date: "    currentDate "\" "
                          "-H \"Signature: keyId='" (uri->string
                                                       (swanye-user-ap-id user)) "',"
                                          "headers='(request-target) host date',"
                                          "signature='" (get-string-all-with-detected-charset baseFilename) "'\" "
                          "-d '" (scm->json-string scmJSON) "' "
                           actorInbox))
          (newline)
          (newline)
          (newline)
          (newline)

          (system (string-append/shared
                    "curl -H \"Content-Type: application/json\" "
                         "-H \"Host: "    (uri-host (string->uri actorInbox)) "\" "
                         "-H \"Date: "    currentDate "\" "
                         "-H \"Signature: keyId='" (uri->string
                                                      (swanye-user-ap-id user)) "',"
                                         "headers='(request-target) host date',"
                                         "signature='" (get-string-all-with-detected-charset baseFilename) "'\" "
                         "-d '" (scm->json-string scmJSON) "' "
                          actorInbox))
          ;; (receive (httpHead httpBody)
          ;;     (http-post actorInbox #:headers `((Host      . ,actorInbox)
          ;;                                       (Date      . ,currentDate)
          ;;                                       (Signature . ,(string-append/shared
          ;;                                                       "keyId=\""
          ;;                                                       userURL
          ;;                                                       "\",headers=\"(request-target) host date\",signature=\""
          ;;                                                       (get-string-all-with-detected-charset baseFilename) "\"")))
          ;;                           #:body    (scm->json-string scmJSON))
          ;;   (system (string-append/shared "rm " baseFilename)))

          (response-emit "OK" #:status 200))
      (response-emit "FUCK" #:status 401))))
