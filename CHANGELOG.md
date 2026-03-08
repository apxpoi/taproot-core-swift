# Changelog

All notable changes to this project are documented in this file.

## [2026.3.x] Unstable

### Added

- Added `Asset.valuationAtUnixMs` for market valuation timestamps.
- Added `PortfolioSnapshot` and `PortfolioSnapshotGroupValue` models.
- Added `SnapshotFXRate` so each snapshot can store the FX table used for base-currency conversion.
- Added `CashFlowEvent` and `CashFlowType` models.
- Added `PortfolioSnapshotBuilder` / `Vault.buildSnapshot(...)` to generate snapshots from live vault assets with mandatory FX coverage for non-base currencies.
- Added validation for snapshots, cash flows, market-asset timestamp requirements, and vault time-series ordering.

### Changed

- Extended `Vault` with `snapshots` and `cashFlows`.
- Updated CLI demo data to include valuation timestamps, a monthly snapshot, and a cash-flow event.

### Breaking

- `Asset` market categories now require `valuationAtUnixMs` during validation.
- `Vault.validate()` now enforces snapshot/cash-flow validation and ordering rules.

## [2026.3.1]

### Added

- Added OSS governance documents: `CONTRIBUTING.md`, `SECURITY.md`, and `CODE_OF_CONDUCT.md`.

### Changed

- Updated README validation guidance.
- Made `Vault.validate()` structural-only (asset/institution checks).
- Added `Vault.validatePortfolioTotal(baseCurrencyTotal:)` for explicit base-currency total limit checks.
- Preserved mixed-currency vault support in encrypt/decrypt flows.

### Security

- Bounded PBKDF2 iteration handling in key derivation and vault container parsing/building.
