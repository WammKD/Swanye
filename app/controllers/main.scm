;; Controller main definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller main) ; DO NOT REMOVE THIS LINE!!!

(use-modules (Swanye utils))

(get "/" #:with-auth "/auth/sign_in"
  (lambda (rc)
    (process-redirect rc "/main/home")))

(main-define home
  (options #:with-auth "/auth/sign_in")

  (lambda (rc)
    (view-render "main" (the-environment))))
