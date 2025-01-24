;; Dimensional Bridge NFT Contract

(define-non-fungible-token dimensional-bridge-nft uint)

(define-data-var token-id-counter uint u0)

(define-map token-metadata uint {
    creator: principal,
    source-dimension: (string-ascii 50),
    target-dimension: (string-ascii 50),
    stability-factor: uint,
    creation-date: uint
})

(define-public (mint-dimensional-bridge (source-dimension (string-ascii 50)) (target-dimension (string-ascii 50)) (stability-factor uint))
    (let
        ((new-id (+ (var-get token-id-counter) u1)))
        (try! (nft-mint? dimensional-bridge-nft new-id tx-sender))
        (map-set token-metadata new-id {
            creator: tx-sender,
            source-dimension: source-dimension,
            target-dimension: target-dimension,
            stability-factor: stability-factor,
            creation-date: block-height
        })
        (var-set token-id-counter new-id)
        (ok new-id)
    )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) (err u403))
        (nft-transfer? dimensional-bridge-nft token-id sender recipient)
    )
)

(define-read-only (get-token-metadata (token-id uint))
    (map-get? token-metadata token-id)
)

(define-read-only (get-last-token-id)
    (var-get token-id-counter)
)

