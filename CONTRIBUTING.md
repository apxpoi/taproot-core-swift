# Contributing

Thank you for helping improve Taproot Core Swift.

## Development Setup

Requirements:
- Swift 6.2+
- macOS 13+

Run:

```bash
swift package resolve
swift build
swift test --parallel
```

## Pull Request Guidelines

- Keep changes focused and minimal.
- Add or update tests for behavior changes.
- Update documentation (`README.md` and `CHANGELOG.md`) when needed.
- Ensure CI passes before requesting review.

## Commit Messages

Use concise, descriptive commit messages. Conventional commit style is preferred, for example:
- `fix(crypto): bound KDF iterations`
- `docs(readme): clarify validation behavior`
