# Taproot Core Swift

Taproot Core Swift is the publicly auditable cryptographic foundation of **Taproot Bookkeeping**.

It provides:

- Encrypted vault container format
- Password-based key derivation
- AES-GCM authenticated encryption
- Portable binary vault structure
- Codable financial data models
- Snapshot and cash-flow primitives for offline trend analysis (including per-snapshot FX rate tables)
- Deterministic snapshot builder API with explicit FX conversion inputs

Taproot Core contains **no UI**, **no analytics**, and **no network calls**.

It is designed to be:

- Offline-first
- Auditable
- Deterministic
- Portable
- Long-term stable

## 🧭 Scope

Taproot Core is the **audit layer**.
It includes:

- Vault format and encryption
- Data models and validation
- Deterministic snapshot building from explicit FX inputs

Taproot product apps are the **experience layer**.
They are not part of this repository:

- UI/UX and chart rendering
- Market/FX data connectors and symbol mapping
- Sync, account systems, and cloud services
- Insight engines, alerts, and commercial workflows

[![CI](https://github.com/apxpoi/taproot-core-swift/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/apxpoi/taproot-core-swift/actions/workflows/ci.yml) [![Security Scan](https://github.com/apxpoi/taproot-core-swift/actions/workflows/security.yml/badge.svg?branch=master)](https://github.com/apxpoi/taproot-core-swift/actions/workflows/security.yml) [![Dependabot Updates](https://github.com/apxpoi/taproot-core-swift/actions/workflows/dependabot/dependabot-updates/badge.svg?branch=master)](https://github.com/apxpoi/taproot-core-swift/actions/workflows/dependabot/dependabot-updates)

Build requirement:

- Swift 6.x

## 🛠️ Build on macOS

Prerequisites:

- macOS 13 or later
- Xcode 16+ (or Swift 6.x toolchain with Command Line Tools)
- Internet access to fetch Swift Package dependencies from GitHub

Build and test:

```bash
# from repository root
swift package resolve
swift build
swift test
```

Run the demo CLI target:

```bash
swift run taproot-core-cli
```

## 📏 System Limits

V1

- Configured max net worth / portfolio total (`TaprootLimitsV1.maxTotalAssetsValue`): `10,000,000,000,000` (10 trillion, base currency units).
- Monetary value storage: `Int64` + `currencyScale` (`0...9`).
- Max single monetary value formula at scale `s`: `Int64.max / 10^s`.
- At maximum precision (`s = 9`), max single value is `9,223,372,036.854775807`.
- At cent precision (`s = 2`), max single value is `92,233,720,368,547,758.07`.
- Use `Vault.validatePortfolioTotal(baseCurrencyTotal:)` after normalizing portfolio values into `baseCurrency`.
- Money string handling limits: `32` chars for processing, `24` chars for display.

## 🔐 Security Model

Taproot Core:

- Uses PBKDF2-HMAC-SHA256 (upgradeable to Argon2id)
- Uses AES-256-GCM for authenticated encryption
- Generates per-vault random salt
- Stores no plaintext financial data
- Makes no network requests

All encryption happens locally.

Taproot Core does not:

- Transmit data
- Collect analytics
- Use cloud services
- Require accounts

## 📦 Vault Format

Binary layout:

```text
| MAGIC HEADER (TAPROOT1) |
| KDF algorithm id (1 byte) |
| KDF iterations (4 bytes, big-endian) |
| salt length (1 byte) |
| salt |
| AES-GCM ciphertext |
```

Ciphertext contains:

- JSON-encoded Vault structure
- Authenticated encryption tag
- Nonce (embedded in combined format)

## 🧱 Project Structure

```text
Sources/
└── TaprootCore/
    ├── Models/
    ├── Crypto/
    ├── Storage/
    ├── ...
    ...
Tests/
```

This repository is the **reference implementation** of the Taproot vault format.

## 🚀 Goals

Taproot Core exists to:

- Provide a publicly auditable vault format
- Build trust through transparency
- Enable independent verification
- Serve as the foundation of Taproot

## 🚫 Non-Goals

This repository does not implement:

- Automated analytics or recommendations
- Data acquisition from exchanges, banks, or APIs
- Subscription, billing, or growth features

## 🔁 Determinism Contract

Given the same vault data, snapshot timestamp, and FX rate table,
`Vault.buildSnapshot(...)` must produce the same snapshot output.
No hidden network state is used.

## 🔧 Versioning & Breaking Changes

- Schema-level changes may be breaking across major evolution points.
- Breaking changes are documented in `CHANGELOG.md`.
- Consumers should pin versions and run full validation on upgrades.

## ™️ Trademark

Code use is governed by `LICENSE`.
Brand use is separate: do not use Taproot names, marks, or logos in a way that implies official affiliation.

## ❗ Non-Commercial License

This project is source-available (MIT + Commons Clause).
It is **not** an OSI-approved open-source license.

You may:

- Use
- Modify
- Redistribute
- Fork

For **non-commercial purposes only**.

You may NOT:

- Sell this software
- Offer it as a paid service
- Build a competing commercial product using this code

See LICENSE for details.

For commercial licensing or partnership, contact the repository maintainers directly.

## ⚠️ Disclaimer

This software is provided "as is" without warranty of any kind.

Use at your own risk.

## 🌱 About Taproot

Taproot is an offline, encrypted, multi-currency personal wealth ledger designed for global citizens.
