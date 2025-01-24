;; Data Validation and Consensus Contract

(define-data-var validation-counter uint u0)

(define-map validations uint {
    transaction-id: uint,
    validator: principal,
    dimension: (string-ascii 50),
    is-valid: bool,
    timestamp: uint
})

(define-map consensus-status uint {
    transaction-id: uint,
    total-validations: uint,
    positive-validations: uint,
    consensus-reached: bool
})

(define-constant CONSENSUS_THRESHOLD u0.75)

(define-public (submit-validation (transaction-id uint) (is-valid bool))
    (let
        ((new-id (+ (var-get validation-counter) u1))
         (current-dimension "prime")) ;; Assuming "prime" is our current dimension
        (map-set validations new-id {
            transaction-id: transaction-id,
            validator: tx-sender,
            dimension: current-dimension,
            is-valid: is-valid,
            timestamp: block-height
        })
        (var-set validation-counter new-id)
        (update-consensus transaction-id is-valid)
        (ok new-id)
    )
)

(define-private (update-consensus (transaction-id uint) (is-valid bool))
    (let
        ((status (default-to
            { transaction-id: transaction-id, total-validations: u0, positive-validations: u0, consensus-reached: false }
            (map-get? consensus-status transaction-id))))
        (map-set consensus-status transaction-id
            (merge status {
                total-validations: (+ (get total-validations status) u1),
                positive-validations: (+ (get positive-validations status) (if is-valid u1 u0))
            }))
        (check-consensus transaction-id)
    )
)

(define-private (check-consensus (transaction-id uint))
    (let
        ((status (unwrap! (map-get? consensus-status transaction-id) false)))
        (if (>= (/ (to-int (get positive-validations status)) (to-int (get total-validations status))) (to-int CONSENSUS_THRESHOLD))
            (map-set consensus-status transaction-id
                (merge status { consensus-reached: true }))
            false
        )
    )
)

(define-read-only (get-validation (validation-id uint))
    (map-get? validations validation-id)
)

(define-read-only (get-consensus-status (transaction-id uint))
    (map-get? consensus-status transaction-id)
)

