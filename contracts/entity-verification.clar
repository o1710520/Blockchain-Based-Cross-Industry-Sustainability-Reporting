;; Entity Verification Contract
;; Validates reporting organizations

(define-data-var admin principal tx-sender)

;; Map of verified entities
(define-map verified-entities principal
  {
    name: (string-utf8 100),
    industry: (string-utf8 50),
    verification-date: uint,
    status: bool
  }
)

;; Public function to register a new entity (admin only)
(define-public (register-entity (entity principal) (name (string-utf8 100)) (industry (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (not (is-some (map-get? verified-entities entity))) (err u101))
    (ok (map-set verified-entities entity
      {
        name: name,
        industry: industry,
        verification-date: block-height,
        status: true
      }
    ))
  )
)

;; Public function to revoke entity verification
(define-public (revoke-entity (entity principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (map-get? verified-entities entity)) (err u102))
    (ok (map-set verified-entities entity
      (merge (unwrap-panic (map-get? verified-entities entity)) { status: false })
    ))
  )
)

;; Read-only function to check if an entity is verified
(define-read-only (is-verified (entity principal))
  (match (map-get? verified-entities entity)
    entity-data (get status entity-data)
    false
  )
)

;; Read-only function to get entity details
(define-read-only (get-entity-details (entity principal))
  (map-get? verified-entities entity)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
