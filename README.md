# Swole

Native, offline-first iOS strength-and-cardio tracker. Manual logging is first-class; Apple Intelligence adds on-device generation and coaching where available.

## Requirements

- Xcode 26+ (Swift 6.3+)
- iOS 18.0+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to regenerate the project from `project.yml`

## Quick start

```bash
brew install xcodegen
xcodegen generate
open Swole.xcodeproj
```

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for folder layout, build/test commands, and conventions. Product requirements live in [docs/DESIGN.md](docs/DESIGN.md); the implementation backlog is [docs/STORIES.md](docs/STORIES.md).
