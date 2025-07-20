;; Emergency Beacon Contract
;; Coordinates search and rescue operations

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u400))
(define-constant ERR-BEACON-NOT-FOUND (err u401))
(define-constant ERR-INVALID-COORDINATES (err u402))
(define-constant ERR-INVALID-INPUT (err u403))
(define-constant ERR-BEACON-ALREADY-RESOLVED (err u404))

;; Data Variables
(define-data-var next-beacon-id uint u1)
(define-data-var next-rescue-id uint u1)

;; Emergency Beacons
(define-map emergency-beacons
  { beacon-id: uint }
  {
    vessel-id: uint,
    vessel-name: (string-ascii 50),
    emergency-type: (string-ascii 30),
    severity: (string-ascii 10),
    latitude: int,
    longitude: int,
    persons-on-board: uint,
    description: (string-ascii 300),
    contact-info: (string-ascii 100),
    activated-by: principal,
    activated-at: uint,
    status: (string-ascii 20),
    resolved-at: (optional uint)
  }
)

;; Rescue Operations
(define-map rescue-operations
  { rescue-id: uint }
  {
    beacon-id: uint,
    rescue-vessel: (string-ascii 50),
    rescue-team: (string-ascii 100),
    coordinator: principal,
    estimated-arrival: uint,
    status: (string-ascii 20),
    started-at: uint,
    completed-at: (optional uint),
    notes: (string-ascii 500)
  }
)

;; Rescue Vessels Registry
(define-map rescue-vessels
  { vessel-id: uint }
  {
    name: (string-ascii 50),
    call-sign: (string-ascii 20),
    operator: principal,
    latitude: int,
    longitude: int,
    capacity: uint,
    equipment: (string-ascii 200),
    available: bool,
    last-update: uint
  }
)

(define-data-var next-rescue-vessel-id uint u1)

;; Emergency Contacts
(define-map emergency-contacts
  { contact-id: uint }
  {
    name: (string-ascii 50),
    organization: (string-ascii 50),
    phone: (string-ascii 20),
    radio-frequency: (string-ascii 20),
    coverage-area: (string-ascii 100),
    contact-type: (string-ascii 30),
    active: bool
  }
)

(define-data-var next-contact-id uint u1)

;; Authorization checks
(define-private (is-rescue-coordinator (caller principal))
  (or (is-eq caller CONTRACT-OWNER)
      ;; Add additional authorization logic for rescue coordinators
      true))

;; Activate emergency beacon
(define-public (activate-emergency-beacon
  (vessel-id uint)
  (vessel-name (string-ascii 50))
  (emergency-type (string-ascii 30))
  (severity (string-ascii 10))
  (latitude int)
  (longitude int)
  (persons-on-board uint)
  (description (string-ascii 300))
  (contact-info (string-ascii 100)))
  (let ((beacon-id (var-get next-beacon-id)))
    (asserts! (> (len vessel-name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len emergency-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len severity) u0) ERR-INVALID-INPUT)
    (asserts! (and (>= latitude -90000000) (<= latitude 90000000)) ERR-INVALID-COORDINATES)
    (asserts! (and (>= longitude -180000000) (<= longitude 180000000)) ERR-INVALID-COORDINATES)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)

    (map-set emergency-beacons
      { beacon-id: beacon-id }
      {
        vessel-id: vessel-id,
        vessel-name: vessel-name,
        emergency-type: emergency-type,
        severity: severity,
        latitude: latitude,
        longitude: longitude,
        persons-on-board: persons-on-board,
        description: description,
        contact-info: contact-info,
        activated-by: tx-sender,
        activated-at: block-height,
        status: "active",
        resolved-at: none
      })

    (var-set next-beacon-id (+ beacon-id u1))
    (ok beacon-id)))

;; Register rescue vessel
(define-public (register-rescue-vessel
  (name (string-ascii 50))
  (call-sign (string-ascii 20))
  (latitude int)
  (longitude int)
  (capacity uint)
  (equipment (string-ascii 200)))
  (let ((vessel-id (var-get next-rescue-vessel-id)))
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len call-sign) u0) ERR-INVALID-INPUT)
    (asserts! (and (>= latitude -90000000) (<= latitude 90000000)) ERR-INVALID-COORDINATES)
    (asserts! (and (>= longitude -180000000) (<= longitude 180000000)) ERR-INVALID-COORDINATES)
    (asserts! (> capacity u0) ERR-INVALID-INPUT)

    (map-set rescue-vessels
      { vessel-id: vessel-id }
      {
        name: name,
        call-sign: call-sign,
        operator: tx-sender,
        latitude: latitude,
        longitude: longitude,
        capacity: capacity,
        equipment: equipment,
        available: true,
        last-update: block-height
      })

    (var-set next-rescue-vessel-id (+ vessel-id u1))
    (ok vessel-id)))

;; Initiate rescue operation
(define-public (initiate-rescue-operation
  (beacon-id uint)
  (rescue-vessel (string-ascii 50))
  (rescue-team (string-ascii 100))
  (estimated-arrival uint)
  (notes (string-ascii 500)))
  (let ((rescue-id (var-get next-rescue-id))
        (beacon (unwrap! (map-get? emergency-beacons { beacon-id: beacon-id }) ERR-BEACON-NOT-FOUND)))
    (asserts! (is-rescue-coordinator tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status beacon) "active") ERR-BEACON-ALREADY-RESOLVED)
    (asserts! (> (len rescue-vessel) u0) ERR-INVALID-INPUT)
    (asserts! (> (len rescue-team) u0) ERR-INVALID-INPUT)
    (asserts! (> estimated-arrival block-height) ERR-INVALID-INPUT)

    (map-set rescue-operations
      { rescue-id: rescue-id }
      {
        beacon-id: beacon-id,
        rescue-vessel: rescue-vessel,
        rescue-team: rescue-team,
        coordinator: tx-sender,
        estimated-arrival: estimated-arrival,
        status: "dispatched",
        started-at: block-height,
        completed-at: none,
        notes: notes
      })

    ;; Update beacon status
    (map-set emergency-beacons
      { beacon-id: beacon-id }
      (merge beacon { status: "rescue-dispatched" }))

    (var-set next-rescue-id (+ rescue-id u1))
    (ok rescue-id)))

;; Update rescue operation status
(define-public (update-rescue-status
  (rescue-id uint)
  (status (string-ascii 20))
  (notes (string-ascii 500)))
  (match (map-get? rescue-operations { rescue-id: rescue-id })
    rescue (begin
             (asserts! (is-eq tx-sender (get coordinator rescue)) ERR-NOT-AUTHORIZED)
             (asserts! (> (len status) u0) ERR-INVALID-INPUT)

             (map-set rescue-operations
               { rescue-id: rescue-id }
               (merge rescue {
                 status: status,
                 notes: notes,
                 completed-at: (if (is-eq status "completed")
                                 (some block-height)
                                 (get completed-at rescue))
               }))

             ;; Update beacon status if rescue completed
             (if (is-eq status "completed")
               (match (map-get? emergency-beacons { beacon-id: (get beacon-id rescue) })
                 beacon (map-set emergency-beacons
                          { beacon-id: (get beacon-id rescue) }
                          (merge beacon {
                            status: "resolved",
                            resolved-at: (some block-height)
                          }))
                 false)
               true)

             (ok true))
    ERR-INVALID-INPUT))

;; Update rescue vessel position
(define-public (update-rescue-vessel-position
  (vessel-id uint)
  (latitude int)
  (longitude int)
  (available bool))
  (match (map-get? rescue-vessels { vessel-id: vessel-id })
    vessel (begin
             (asserts! (is-eq tx-sender (get operator vessel)) ERR-NOT-AUTHORIZED)
             (asserts! (and (>= latitude -90000000) (<= latitude 90000000)) ERR-INVALID-COORDINATES)
             (asserts! (and (>= longitude -180000000) (<= longitude 180000000)) ERR-INVALID-COORDINATES)

             (map-set rescue-vessels
               { vessel-id: vessel-id }
               (merge vessel {
                 latitude: latitude,
                 longitude: longitude,
                 available: available,
                 last-update: block-height
               }))
             (ok true))
    ERR-INVALID-INPUT))

;; Add emergency contact
(define-public (add-emergency-contact
  (name (string-ascii 50))
  (organization (string-ascii 50))
  (phone (string-ascii 20))
  (radio-frequency (string-ascii 20))
  (coverage-area (string-ascii 100))
  (contact-type (string-ascii 30)))
  (let ((contact-id (var-get next-contact-id)))
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len organization) u0) ERR-INVALID-INPUT)
    (asserts! (> (len contact-type) u0) ERR-INVALID-INPUT)

    (map-set emergency-contacts
      { contact-id: contact-id }
      {
        name: name,
        organization: organization,
        phone: phone,
        radio-frequency: radio-frequency,
        coverage-area: coverage-area,
        contact-type: contact-type,
        active: true
      })

    (var-set next-contact-id (+ contact-id u1))
    (ok contact-id)))

;; Read-only functions
(define-read-only (get-emergency-beacon (beacon-id uint))
  (map-get? emergency-beacons { beacon-id: beacon-id }))

(define-read-only (get-rescue-operation (rescue-id uint))
  (map-get? rescue-operations { rescue-id: rescue-id }))

(define-read-only (get-rescue-vessel (vessel-id uint))
  (map-get? rescue-vessels { vessel-id: vessel-id }))

(define-read-only (get-emergency-contact (contact-id uint))
  (map-get? emergency-contacts { contact-id: contact-id }))

(define-read-only (get-total-beacons)
  (- (var-get next-beacon-id) u1))

(define-read-only (get-total-rescue-operations)
  (- (var-get next-rescue-id) u1))

(define-read-only (get-total-rescue-vessels)
  (- (var-get next-rescue-vessel-id) u1))

;; Cancel emergency beacon (if false alarm)
(define-public (cancel-emergency-beacon (beacon-id uint))
  (match (map-get? emergency-beacons { beacon-id: beacon-id })
    beacon (begin
             (asserts! (is-eq tx-sender (get activated-by beacon)) ERR-NOT-AUTHORIZED)
             (asserts! (is-eq (get status beacon) "active") ERR-BEACON-ALREADY-RESOLVED)

             (map-set emergency-beacons
               { beacon-id: beacon-id }
               (merge beacon {
                 status: "cancelled",
                 resolved-at: (some block-height)
               }))
             (ok true))
    ERR-BEACON-NOT-FOUND))
