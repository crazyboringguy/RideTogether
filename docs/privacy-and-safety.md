# Privacy and safety

## Phase 3 status

Phase 2 does not collect, transmit, store, or display a person's location. It stores a display
name, normalized email address, Argon2id password hash, and server-side session metadata for
authenticated accounts. Passwords are never stored or logged in plaintext.

## Required principles for later phases

- Location sharing must be explicit, visible, and easy to stop; leaving a trip must stop it.
- Location history must have a documented, limited retention period and deletion path.
- Family links must use high-entropy, revocable, expiring tokens and expose a read-only subset of
  trip data. Group chat must remain private by default.
- Emergency features must communicate delivery and accuracy limits clearly.
- Separation signals are GPS-based coordination indicators, never a guarantee of safety.
- Gamification must reward preparedness and group coordination, never speed or risky behavior.

Privacy language, consent UX, retention policy, and regional compliance review must be complete
before live location functionality is released.
