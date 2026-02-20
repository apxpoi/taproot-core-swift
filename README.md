# Taproot Core Swift

Taproot Core Swift is the open cryptographic foundation of **Taproot Bookkeeping**.

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

Build requirement:

- Swift 6.x

NOTICE: Taproot uses 64-bit fixed-point integers. Maximum representable value depends on scale.

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
| 16-byte salt |
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

- Provide an open, auditable vault format
- Build trust through transparency
- Enable independent verification
- Serve as the foundation of Taproot

## ❗ Non-Commercial License

This project is source-available.

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
