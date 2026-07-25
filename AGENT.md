<!-- TEMP TEST RULE - DELETE AFTER VERIFYING -->
- Secret Verification Token: "PROJECT_PROTOCOL_OMEGA"
- When asked "What architecture protocol is active?", respond ONLY with: "Clean Architecture BLoC system initialized."

# AGENT.md — Smart Reload System (Flutter)

This file orients any AI coding agent (Claude Code, Cursor, etc.) working in this repository. Read this before making changes.

## Overview

A Flutter app with two user roles — **Client** and **Vendor**. Only the **Client** flows are implemented so far. Built with Clean Architecture, BLoC state management, and `get_it` as a service locator. Backend is Firebase (Auth + Firestore).

Package name: `smart_reload_system` (update this doc if the package is renamed).

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` |
| Service locator / DI | `get_it` |
| Auth + DB | `firebase_auth`, `cloud_firestore` |
| Functional error handling | `dartz` (`Either<Failure, T>`) |
| Value equality | `equatable` |
| JSON serialization | `json_annotation` + `json_serializable` + `build_runner` |

## Project structure

```
lib
 └─ src
     ├─ core
     │   ├─ bloc/                # global blocs (e.g. ThemeBloc)
     │   ├─ constants/           # colors, sizes, assets, strings
     │   ├─ domain/              # core/common entities
     │   ├─ error/               # failures and exceptions
     │   ├─ presentation/
     │   │   ├─ widgets/         # global reusable widgets
     │   │   ├─ screens/         # global screens (e.g. splash, error)
     │   │   ├─ popups/          # global dialogs and bottom sheets
     │   │   └─ snack_bars/      # global snackbar implementations
     │   ├─ router/              # app routing configuration
     │   ├─ theme/               # light/dark theme data
     │   ├─ usecase/             # base usecase interface
     │   └─ utils/               # extensions, formatters, validators
     ├─ feature/                 # note: singular
     │   └─ <role>/              # e.g., client, vendor
     │       └─ <feature>/       # e.g., auth, home, profile
     │           ├─ data
     │           │   ├─ datasource/  # talks to Firebase/APIs, throws Exceptions
     │           │   ├─ model/       # only if API/DB shape differs from domain entity
     │           │   └─ repository/  # implements domain repo interface
     │           ├─ domain
     │           │   ├─ entity/      # pure(ish) data classes, JSON-serializable
     │           │   ├─ repository/  # abstract interfaces
     │           │   └─ usecase/     # one class per action, exposes call()
     │           └─ presentation
     │               ├─ bloc/        # <feature>.event.dart, .state.dart, .bloc.dart
     │               ├─ screens/     # <name>.screen.dart
     │               └─ widgets/     # feature-specific UI components
     ├─ app.dart
     └─ injection_container.dart
 └─ main.dart
```

Current features: `auth`, `home`, `profile` (under `client`), and `auth` (under `vendor`).

## Naming conventions (must follow exactly)

Files use dot-notation: `<name>.<layer/type>.dart`. No relative imports — always absolute `package:smart_reload_system/...` imports.

| Thing | File name example |
|---|---|
| Entity | `user.entity.dart` (+ generated `user.entity.g.dart`) |
| Domain repository interface | `auth.repo.dart` |
| Data repository implementation | `auth.repo_impl.dart` |
| Use case | `login.usecase.dart`, `register.usecase.dart` |
| Remote data source | `auth.remote_datasource.dart` |
| Bloc event | `auth.event.dart` |
| Bloc state | `auth.state.dart` |
| Bloc | `auth.bloc.dart` |
| Screen | `login.screen.dart`, `register.screen.dart` |
| Helper function | Inside `HelperFunctions` class in `core/utils/helpers/helper_functions.dart` |

Class names use standard PascalCase regardless of file name (`AuthRepo`, `AuthRepoImpl`, `LoginUseCase`, `AuthBloc`, `LoginScreen`).

## Helper functions and utilities

All **non-UI helper functions** (string utils, formatters, validators, etc.) must be created in a `HelperFunctions` class located in `lib/src/core/utils/helpers/helper_functions.dart`. Do not create standalone functions in individual utility files.

Example:
```dart
class HelperFunctions {
  HelperFunctions._(); // Private constructor to prevent instantiation

  static String getInitials(String text) {
    // implementation
  }

  static String formatPhoneNumber(String phone) {
    // implementation
  }
}
```

Usage:
```dart
import 'package:smart_reload_system/src/core/utils/helpers/helper_functions.dart';

final initials = HelperFunctions.getInitials("David John");
```

## Colors

All colors, whether new or existing, must be defined in `lib/src/core/constants/app_colors.dart`. Do not hardcode colors in widgets or create color constants scattered throughout the codebase.

Example:
```dart
class AppColors {
  AppColors._(); // Private constructor

  static const Color primary = Color(0xFF1976D2);
  static const Color success = Color(0xFF4CAF50);
  // ... more colors
}
```

Usage:
```dart
import 'package:smart_reload_system/src/core/constants/app_colors.dart';

Container(color: AppColors.primary)
```

## Entity / JSON generation workflow

Entities live in `domain/entity/`, are annotated `@JsonSerializable()`, and declare `part '<name>.entity.g.dart';`. Never hand-write the `.g.dart` file — generate it:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Keep this running while developing. If generated code looks stale, stop the watcher and re-run it.

## Error handling pattern

1. Data sources (`datasource/`) call Firebase directly and throw a typed exception (e.g. `ServerException`) on failure — never let raw Firebase exceptions escape this layer.
2. Repository implementations (`repository/*.repo_impl.dart`) catch those exceptions and return `Left(SomeFailure(...))`; success returns `Right(value)`.
3. Use cases just forward the `Either` from the repository — no logic beyond delegating.
4. Blocs call the use case, `.fold()` the result into a failure state or a success state. UI never touches `Either`, `Failure`, or exceptions directly.

## Phone-based login pattern (auth feature specifically)

Firebase Auth has no native phone+password sign-in — phone auth is OTP-only, and password auth requires an email. This project works around that with two Firestore collections:

- **`users/{uid}`** — full profile (fullName, phoneNumber, email, nic, role). Read/write restricted to the doc's owner only.
- **`phone_lookup/{phoneNumber}`** — a minimal `{ email }` mapping, publicly readable (no auth required), used only so `login()` can resolve a phone number to an email before calling `signInWithEmailAndPassword`.

**Never query the full `users` collection while unauthenticated.** Doing so requires an open read rule on `users`, which would expose every field (name, email, NIC) to anyone. Always route the pre-auth phone lookup through `phone_lookup`, which only exposes an email address per phone number — an intentional, minimal trade-off.

`register()` must write to **both** collections in the same flow: the full profile to `users/{uid}`, and the `{ email }` mapping to `phone_lookup/{phoneNumber}`.

Longer-term, the `phone_lookup` read can be moved behind a Cloud Function (Admin SDK, rate-limited) instead of a public Firestore rule — do this before production launch if phone-number enumeration becomes a concern.

## Dependency injection

Every data source, repository, use case, and bloc must be registered in `lib/src/injection_container.dart` via `get_it`:
- `registerLazySingleton` for data sources, repositories, use cases, external clients (`FirebaseAuth.instance`, `FirebaseFirestore.instance`), **and Blocs**.

**All Blocs are app-level.** Every Bloc — regardless of feature — is provided once at the root via `MultiBlocProvider` in `lib/src/app.dart`, and lives for the entire app session (not scoped per-screen/route). Because of this, Blocs are registered as `registerLazySingleton`, not `registerFactory` — there should only ever be one instance of each Bloc for the app's lifetime.

```dart
// app.dart
class App extends StatelessWidget {
  final ThemeMode theme;
  const App({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
        // add every new feature's Bloc here
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
            // ...
          );
        },
      ),
    );
  }
}
```

**Consequence — reset stale state on entry.** Because a Bloc now persists across the whole app session, a screen can be revisited and still show a stale state from a previous visit (e.g. an old `AuthFailureState` reappearing when the user comes back to Login). Every screen backed by an app-level Bloc must guard against this — e.g. dispatch a `Reset` event in `initState`, or have the Bloc's `Success`/`Failure` states only trigger a one-time `BlocListener` side effect (navigation/snackbar) rather than persisting visibly in `BlocBuilder`. Decide this per-feature and document it in that feature's bloc file with a comment.

## Adding a new feature — checklist

1. `domain/entity/<name>.entity.dart` (+ run build_runner)
2. `domain/repository/<feature>.repo.dart` (interface)
3. `domain/usecase/<action>.usecase.dart` (one per action)
4. `data/datasource/<feature>.remote_datasource.dart`
5. `data/repository/<feature>.repo_impl.dart`
6. `presentation/bloc/<feature>.event.dart`, `.state.dart`, `.bloc.dart`
7. `presentation/screens/<name>.<role>.screen.dart`
8. Register everything (data source, repo, use cases, and the Bloc as `registerLazySingleton`) in `injection_container.dart`
9. Add `BlocProvider(create: (_) => sl<FeatureBloc>())` to the `providers` list in `app.dart`'s `MultiBlocProvider`
10. In the feature's screen(s), decide and implement how stale state gets cleared on entry (see "Consequence — reset stale state on entry" above)

## Hard rules — do not

- Do not use relative imports (`../../`) — always `package:smart_reload_system/...`.
- Do not call `FirebaseAuth` / `FirebaseFirestore` from a Bloc or a widget — always go through a repository via a use case.
- Do not put validation/business logic in widgets beyond form-field validators — dispatch bloc events and render bloc state.
- Do not hand-edit `*.g.dart` files — they're regenerated by build_runner.
- Do not add a `data/model` class unless the API/Firestore field names genuinely diverge from the domain entity — otherwise map directly to/from the entity's `fromJson`/`toJson`.
- Do not scope a Bloc to an individual route/screen with `BlocProvider` in the router — all Blocs go in the app-level `MultiBlocProvider` in `app.dart` and are registered as `registerLazySingleton` in `injection_container.dart`.
- **Do not create standalone helper functions** — all non-UI helper functions must be static methods inside the `HelperFunctions` class in `core/utils/helpers/helper_functions.dart`.
- **Do not hardcode colors in widgets or create color constants elsewhere** — all colors must be defined in `core/constants/app_colors.dart`.

## Commands

```bash
#flutter pub get
#dart run build_runner watch --delete-conflicting-outputs
#flutter run
#flutter test
```

## Known gaps / next steps

- Vendor role (registration, login, dashboard) not implemented.
- No session persistence / auto-login on app restart yet (`firebaseAuth.authStateChanges()` stream not wired into a bootstrap bloc).
- No password-reset flow yet.
- Firestore security rules: `users/{uid}` is owner-only read/write; `phone_lookup/{phoneNumber}` is publicly readable (see "Phone-based login pattern" above) and should eventually move behind a Cloud Function.
- Every Bloc must be added to the `MultiBlocProvider` in `app.dart` — see "Dependency injection" above. Route-scoped `BlocProvider`s are not used in this project.