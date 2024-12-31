(define-fungible-token reward-token)

(define-map rewards
  { recipient: principal }
  { amount: uint })

(define-public (mint-tokens (recipient principal) (amount uint))
  (begin
    (ft-mint? reward-token amount recipient)
    (map-set rewards { recipient: recipient } { amount: amount })
    (ok "Tokens minted successfully")))

(define-read-only (get-rewards (recipient principal))
  (default-to u0 (get amount (map-get rewards { recipient: recipient }))))
