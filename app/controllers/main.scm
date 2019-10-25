;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller main) ; DO NOT REMOVE THIS LINE!!!

(get "/" #:with-auth "/auth/sign_in"
  (lambda (rc)
    (view-render "dashboard" (the-environment))))

