---
name: flutter-clean-arch-feature
description: Use this skill when adding, scaffolding, or modifying a feature in the Smart Reload System Flutter app — entities, repositories, use cases, data sources, blocs, or screens. Triggers on requests like "add a new feature", "create a repository/usecase/bloc", "add a screen", "wire up a new entity", or any file under lib/src/features/. Ensures new code matches this project's Clean Architecture + BLoC + get_it conventions exactly.
---

# Flutter Clean Architecture Feature Scaffolding

This skill scaffolds a new feature (or extends an existing one) inside `lib/src/features/<feature_name>/` following this project's established structure. See `AGENT.md` at the repo root for the full rulebook — this skill is the executable version of it.

## When to use

- User asks to add a new feature end-to-end (e.g. "add a wallet top-up feature").
- User asks to add just one layer (e.g. "add a usecase for fetching transaction history").
- User asks to add a new entity, screen, or bloc to an existing feature.

## Steps

1. **Confirm the feature name and package name.** Default package name is `smart_reload_system` unless `pubspec.yaml` says otherwise — check it if unsure.

2. **Create files in this order**, using the templates below with `{Feature}` / `{feature}` / `{Entity}` / `{entity}` replaced:

   1. `domain/entity/{entity}.entity.dart` — annotate with `@JsonSerializable()`, add `part '{entity}.entity.g.dart';`. Do not write the `.g.dart` file by hand.
   2. `domain/repository/{feature}.repo.dart` — abstract interface, methods return `Future<Either<Failure, T>>`.
   3. `domain/usecase/{action}.usecase.dart` — one class per action, single `call()` method, just delegates to the repo.
   4. `data/datasource/{feature}.remote_datasource.dart` — talks to Firebase directly, throws `ServerException` (from `core/error/exceptions.dart`) on failure. Never leak raw `FirebaseException`/`FirebaseAuthException` past this layer.
   5. `data/repository/{feature}.repo_impl.dart` — implements the domain interface, catches the datasource's exceptions, converts to `Left(Failure(...))`.
   6. `presentation/bloc/{feature}.event.dart`, `{feature}.state.dart`, `{feature}.bloc.dart` — bloc calls the usecase and `.fold()`s the `Either` into failure/success states.
   7. `presentation/screens/{name}.screen.dart` — dispatches bloc events from `onPressed`/`onSubmit`, renders state via `BlocBuilder`/`BlocListener`. No direct Firebase calls, no business logic.

3. **Register every new binding** in `lib/src/injection_container.dart` using `registerLazySingleton` — data sources, repositories, use cases, **and the bloc**. Blocs are singletons here because they live for the whole app session (see step 5).

4. **Run build_runner** if any entity changed: `dart run build_runner watch --delete-conflicting-outputs`.

5. **Add the new Bloc to the app-level `MultiBlocProvider`** in `lib/src/app.dart` — do not scope it to a route:

   ```dart
   MultiBlocProvider(
     providers: [
       BlocProvider(create: (_) => sl<ThemeBloc>()),
       BlocProvider(create: (_) => sl<AuthBloc>()),
       BlocProvider(create: (_) => sl<{Feature}Bloc>()), // new bloc goes here
     ],
     child: /* ... */,
   )
   ```

   Because this Bloc now persists for the app's lifetime, the screen(s) using it must guard against stale state on re-entry (e.g. an old failure/success state reappearing on a repeat visit). Handle this explicitly — dispatch a `Reset` event in `initState`, or treat success/failure as one-shot `BlocListener` side effects rather than values rendered by `BlocBuilder`.

## File naming reference

Always dot-notation, always absolute imports (`package:smart_reload_system/...`), never relative (`../../`):

```
{entity}.entity.dart          user.entity.dart
{feature}.repo.dart           auth.repo.dart
{feature}.repo_impl.dart      auth.repo_impl.dart
{action}.usecase.dart         login.usecase.dart
{feature}.remote_datasource.dart   auth.remote_datasource.dart
{feature}.event.dart          auth.event.dart
{feature}.state.dart          auth.state.dart
{feature}.bloc.dart           auth.bloc.dart
{name}.screen.dart            login.screen.dart
```

## Templates

### Entity
```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '{entity}.entity.g.dart';

@JsonSerializable()
class {Entity}Entity extends Equatable {
// fields here

const {Entity}Entity();

factory {Entity}Entity.fromJson(Map<String, dynamic> json) => _${Entity}EntityFromJson(json);
Map<String, dynamic> toJson() => _${Entity}EntityToJson(this);

@override
List<Object?> get props => [];
}
```

### Repository interface
```dart
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';

abstract class {Feature}Repo {
Future<Either<Failure, /* return type */>> someAction(/* params */);
}
```

### Use case
```dart
import 'package:dartz/dartz.dart';
import 'package:smart_reload_system/src/core/error/failures.dart';
import 'package:smart_reload_system/src/features/{feature}/domain/repository/{feature}.repo.dart';

class {Action}UseCase {
final {Feature}Repo repo;
{Action}UseCase(this.repo);

Future<Either<Failure, /* return type */>> call(/* params */) {
return repo.someAction(/* params */);
}
}
```

### Bloc skeleton
```dart
// {feature}.event.dart — abstract class {Feature}Event extends Equatable + concrete event classes
// {feature}.state.dart — abstract class {Feature}State extends Equatable + Initial/Loading/Success/FailureState
// {feature}.bloc.dart:
class {Feature}Bloc extends Bloc<{Feature}Event, {Feature}State> {
final {Action}UseCase {action}UseCase;
{Feature}Bloc({required this.{action}UseCase}) : super({Feature}Initial()) {
on<SomeRequested>(_onSomeRequested);
}

Future<void> _onSomeRequested(SomeRequested event, Emitter<{Feature}State> emit) async {
emit({Feature}Loading());
final result = await {action}UseCase(/* params */);
result.fold(
(failure) => emit({Feature}FailureState(failure.message)),
(value) => emit({Feature}Success(value)),
);
}
}
```

## Reference implementation

The `auth` feature (Client login + registration) is the canonical example of every rule above — mirror its structure for any new feature.

**Special case — public/pre-auth reads.** If a new feature ever needs to read Firestore data *before* the user is signed in (the way login needs to resolve a phone number to an email), never widen read access on a collection containing full profile/PII data. Instead create a narrow, single-purpose collection exposing only the minimum field needed (see `phone_lookup/{phoneNumber} -> { email }` in the `auth` feature), and query that instead. Document any such collection in `AGENT.md` under "Known gaps / next steps" along with its security rule.

## Hard rules (never violate)

- No relative imports.
- No direct Firebase calls outside `data/datasource/`.
- No hand-edited `.g.dart` files.
- No business logic in widgets.
- No route-scoped `BlocProvider` — every Bloc is added to the app-level `MultiBlocProvider` in `app.dart` and registered as `registerLazySingleton`.
- Every new binding gets registered in `injection_container.dart` in the same change, and every new Bloc gets added to `app.dart` in the same change.