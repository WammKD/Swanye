;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller profiles) ; DO NOT REMOVE THIS LINE!!!

(use-modules (Swanye database-getters) (Swanye utils) (web uri))

(profiles-define :actorID
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (if-let ([id (string->number (params rc "actorID"))])
        (if-let ([actors null? (get-actors-where #:ACTOR_ID id)])
            "invalid"
          (let ([actor (car actors)])
            (view-render "page" (the-environment))))
      "invalid")))
