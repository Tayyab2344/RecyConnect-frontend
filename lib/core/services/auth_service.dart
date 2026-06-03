// Backward-compatibility bridge.
//
// The old AuthService (which was a god-class doing everything) has been
// refactored into Clean Architecture layers:
//   - Domain: entities, repository interface, use cases
//   - Data: DTOs, data sources, repository implementation
//   - Presentation: AuthProvider
//
// This file re-exports AuthProvider as AuthService so that ALL existing
// screens (30+ files) that do:
//   import '../../../core/services/auth_service.dart';
//   Provider.of<AuthService>(context, listen: false)
//
// continue to work WITHOUT any changes.
//
// The type alias makes AuthService = AuthProvider, so the provider tree
// and all Consumer<AuthService> / Provider.of<AuthService> calls still resolve.
//
// To migrate a screen to the new architecture, simply change:
//   import '../../../core/services/auth_service.dart'
// to:
//   import 'package:recyconnect/features/auth/presentation/providers/auth_provider.dart'
// and replace AuthService with AuthProvider.

export 'package:recyconnect/features/auth/presentation/providers/auth_provider.dart'
    show AuthProvider;

// Type alias for backward compatibility
// This allows existing code using `AuthService` type to continue working.
import 'package:recyconnect/features/auth/presentation/providers/auth_provider.dart';

typedef AuthService = AuthProvider;
