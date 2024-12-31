(define-set registered-users principal)

(define-public (register)
  (begin
    (if (set-has? registered-users tx-sender)
        (err "User already registered")
        (set-insert registered-users tx-sender))
    (ok "User registered successfully")))

(define-read-only (is-registered (user principal))
  (ok (set-has? registered-users user)))
