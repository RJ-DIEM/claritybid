(define-map auctions
  { auction-id: uint }
  { creator: principal, end-block: uint, highest-bid: uint, highest-bidder: principal })

(define-map bids
  { auction-id: uint, bidder: principal }
  { bid-amount: uint })

(define-public (create-auction (auction-id uint) (end-block uint))
  (begin
    (asserts! (< block-height end-block) (err "End block must be in the future"))
    (map-set auctions
      { auction-id: auction-id }
      { creator: tx-sender, end-block: end-block, highest-bid: u0, highest-bidder: tx-sender })
    (ok "Auction created successfully")))

(define-public (place-bid (auction-id uint) (bid-amount uint))
  (let ((auction (map-get? auctions { auction-id: auction-id })))
    (match auction
      auction-data
      (begin
        (asserts! (<= block-height (get end-block auction-data)) (err "Auction has ended"))
        (asserts! (> bid-amount (get highest-bid auction-data)) (err "Bid must be higher"))
        (map-set bids { auction-id: auction-id, bidder: tx-sender } { bid-amount: bid-amount })
        (map-update auctions { auction-id: auction-id }
          (fn (data { creator: principal, end-block: uint, highest-bid: uint, highest-bidder: principal })
            { creator: (get creator data),
              end-block: (get end-block data),
              highest-bid: bid-amount,
              highest-bidder: tx-sender }))
        (ok "Bid placed successfully")))
      (err "Auction not found"))))

(define-public (finalize-auction (auction-id uint))
  (let ((auction (map-get? auctions { auction-id: auction-id })))
    (match auction
      auction-data
      (begin
        (asserts! (> block-height (get end-block auction-data)) (err "Auction is still ongoing"))
        (asserts! (is-eq (get creator auction-data) tx-sender) (err "Only the creator can finalize"))
        (map-delete auctions { auction-id: auction-id })
        (ok { winner: (get highest-bidder auction-data), winning-bid: (get highest-bid auction-data) }))
      (err "Auction not found"))))
