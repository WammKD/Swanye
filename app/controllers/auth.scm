;; Controller auth definition of myapp
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(define-artanis-controller auth) ; DO NOT REMOVE THIS LINE!!!

(auth-define sign_in
  (lambda (rc)
    "<h1>This is auth#sign_in</h1><p>Find me in app/views/auth/sign_in.html.tpl</p>"
    ;; TODO: add controller method `sign_in'
    ;; uncomment this line if you want to render view from template
    ;; (view-render "sign_in" (the-environment))
  ))

(auth-define sign_up
  (lambda (rc)
  ))
    "<h1>This is auth#sign_up</h1><p>Find me in app/views/auth/sign_up.html.tpl</p>"
    ;; TODO: add controller method `sign_up'
    ;; uncomment this line if you want to render view from template
    (view-render "sign_up" (the-environment))))

(auth-define password
  (lambda (rc)
  "<h1>This is auth#password</h1><p>Find me in app/views/auth/password.html.tpl</p>"
  ;; TODO: add controller method `password'
  ;; uncomment this line if you want to render view from template
  ;; (view-render "password" (the-environment))
  ))

(auth-define confirmation
  (lambda (rc)
  "<h1>This is auth#confirmation</h1><p>Find me in app/views/auth/confirmation.html.tpl</p>"
  ;; TODO: add controller method `confirmation'
  ;; uncomment this line if you want to render view from template
  ;; (view-render "confirmation" (the-environment))
  ))

