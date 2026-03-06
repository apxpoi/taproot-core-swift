# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Changed

- Updated README validation guidance.
- Made `Vault.validate()` structural-only (asset/institution checks).
- Added `Vault.validatePortfolioTotal(baseCurrencyTotal:)` for explicit base-currency total limit checks.
- Preserved mixed-currency vault support in encrypt/decrypt flows.

### Security

- Bounded PBKDF2 iteration handling in key derivation and vault container parsing/building.
