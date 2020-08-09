;; Migration ENDPOINTS_20200808225126 definition of Swanye
;; Please add your license header here.
;; This file is generated automatically by GNU Artanis.
(create-artanis-migration ENDPOINTS_20200808225126) ; DO NOT REMOVE THIS LINE!!!

(migrate-create
  (create-table
    'ENDPOINTS
    '(ACTOR_ID                     big-integer (#:primary-key #:not-null #:unique))
    ;; Endpoint URI so this actor's clients may access remote ActivityStreams
    ;; objects which require authentication to access. To use this endpoint, the
    ;; client posts an `x-www-form-urlencoded` id parameter with the value being
    ;; the `id` of the requested ActivityStreams object.
    '(PROXY_URL                    text)
    ;; If OAuth 2.0 bearer tokens [RFC6749] [RFC6750] are being used for
    ;; authenticating client to server interactions, this endpoint specifies a
    ;; URI at which a browser-authenticated user may obtain a new authorization
    ;; grant.
    '(OAUTH_AUTHORIZATION_ENDPOINT text)
    ;; If OAuth 2.0 bearer tokens [RFC6749] [RFC6750] are being used for
    ;; authenticating client to server interactions, this endpoint specifies a
    ;; URI at which a client may acquire an access token.
    '(OAUTH_TOKEN_ENDPOINT         text)
    ;; If Linked Data Signatures and HTTP Signatures are being used for
    ;; authentication and authorization, this endpoint specifies a URI at which
    ;; browser-authenticated users may authorize a client's public key for
    ;; client to server interactions.
    '(PROVIDE_CLIENT_KEY           text)
    ;; If Linked Data Signatures and HTTP Signatures are being used for
    ;; authentication and authorization, this endpoint specifies a URI at which
    ;; a client key may be signed by the actor's key for a time window to act on
    ;; behalf of the actor in interacting with foreign servers.
    '(   SIGN_CLIENT_KEY           text)
    ;; An optional endpoint used for wide delivery of publicly addressed
    ;; activities and activities sent to followers. `sharedInbox` endpoints
    ;; SHOULD also be publicly readable `OrderedCollection` objects containing
    ;; objects addressed to the Public special collection. Reading from the
    ;; `sharedInbox` endpoint MUST NOT present objects which are not addressed
    ;; to the Public endpoint.
    '(SHARED_INBOX                 text))
(migrate-up
  (display "Add your up code\n"))
(migrate-down
  (drop-table 'ENDPOINTS))
