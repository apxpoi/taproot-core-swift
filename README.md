# Taproot Core Swift

Taproot Core Swift is the publicly auditable cryptographic foundation of **Taproot Bookkeeping**.

It provides:

- Encrypted vault container format
- Password-based key derivation
- AES-GCM authenticated encryption
- Portable binary vault structure
- Codable financial data models

Taproot Core contains **no UI**, **no analytics**, and **no network calls**.

It is designed to be:

- Offline-first
- Auditable
- Deterministic
- Portable
- Long-term stable

[![CI](https://github.com/apxpoi/taproot-core-swift/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/apxpoi/taproot-core-swift/actions/workflows/ci.yml) [![Security Scan](https://github.com/apxpoi/taproot-core-swift/actions/workflows/security.yml/badge.svg?branch=master)](https://github.com/apxpoi/taproot-core-swift/actions/workflows/security.yml) [![Dependabot Updates](https://github.com/apxpoi/taproot-core-swift/actions/workflows/dependabot/dependabot-updates/badge.svg?branch=master)](https://github.com/apxpoi/taproot-core-swift/actions/workflows/dependabot/dependabot-updates)

Build requirement:

- Swift 6.x

## 🛠️ Build on macOS

Prerequisites:

- macOS 13 or later
- Xcode 16+ (or Swift 6.x toolchain with Command Line Tools)
- Local dependency available at `../../giant-stone/iso3166-swift`

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

## ⚠️ Disclaimer

This software is provided "as is" without warranty of any kind.

Use at your own risk.

## 🌱 About Taproot

Taproot is an offline, encrypted, multi-currency personal wealth ledger designed for global citizens.
