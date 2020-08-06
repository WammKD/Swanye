;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller settings) ; DO NOT REMOVE THIS LINE!!!

(settings-define account
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (view-render "account" (the-environment))))
