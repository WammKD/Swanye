;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller main) ; DO NOT REMOVE THIS LINE!!!

(get "/" #:session #t
  (lambda (rc)
    (if (:session rc 'check)
        (redirect-to rc "/auth/sign_in" #:scheme 'https)
      (view-render "dashboard" (the-environment)))))
