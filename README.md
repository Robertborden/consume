# CONSUME

> Save Less. Consume More.

A cross-platform bookmark manager with accountability features for iOS, Android, and Web.

## Overview

CONSUME helps users actually consume the content they save from social media. Instead of hoarding bookmarks that never get viewed, CONSUME adds accountability through:

- **Expiration System**: Content expires if not consumed
- **Swipe Review**: Tinder-style interface for quick decisions
- **Guilt Meter**: Visual accountability for consumption rate
- **Streaks**: Gamification to encourage daily review
- **Statistics**: Track your consumption habits

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.16+ |
| Language | Dart 3.2+ |
| State Management | Riverpod |
| Local Database | Drift (SQLite) |
| Backend | Supabase |
| Subscriptions | RevenueCat |

## Platforms

- iOS (App Store)
- Android (Google Play)
- Web (PWA)

## Features

### MVP Features
- [ ] Share Intent/Extension (save from any app)
- [ ] Home feed with saved items
- [ ] Folder organization
- [ ] Swipe review interface
- [ ] Daily reminder notifications
- [ ] Content expiration
- [ ] User authentication

### Accountability Features
- [ ] Guilt meter visualization
- [ ] Streak tracking
- [ ] Statistics dashboard
- [ ] Achievement badges

## Getting Started

### Prerequisites

- Flutter SDK 3.16+
- Dart SDK 3.2+
- Android Studio / Xcode
- Supabase account

### Installation

```bash
# Clone the repository
git clone https://github.com/Robertborden/consume.git
cd consume

# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment Setup

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Copy your API credentials
3. Create `lib/core/constants/api_constants.dart` from the example file

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App widget
├── core/                     # Core utilities
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── errors/
├── data/                     # Data layer
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/                   # Domain layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/             # UI layer
│   ├── providers/
│   ├── pages/
│   ├── widgets/
│   └── router/
└── services/                 # Platform services
```

## Architecture

This project follows **Clean Architecture** with a feature-first approach:

- **Presentation Layer**: UI, widgets, state management (Riverpod)
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: Repositories, data sources, models

## License

This project is proprietary. All rights reserved.

## Contact

- GitHub: [@Robertborden](https://github.com/Robertborden)
