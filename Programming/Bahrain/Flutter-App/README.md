# Virtual Hospital Flutter App

Flutter implementation of the Virtual Hospital application using Domain-Driven Design (DDD) architecture.

## Architecture

This project follows DDD principles with the following layers:

- **Domain**: Core business logic, entities, value objects, and repository interfaces
- **Application**: Use cases, DTOs, and application services
- **Infrastructure**: Data sources, repository implementations, and external services
- **Presentation**: UI components, state management, and navigation

## Project Structure

```
lib/
├── domain/
│   ├── entities/
│   ├── value_objects/
│   └── repositories/
├── application/
│   ├── use_cases/
│   └── dtos/
├── infrastructure/
│   ├── data_sources/
│   └── repositories/
└── presentation/
    ├── pages/
    ├── widgets/
    ├── providers/
    └── theme/
```

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
flutter run
```
