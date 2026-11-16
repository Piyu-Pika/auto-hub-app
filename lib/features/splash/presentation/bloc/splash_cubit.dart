import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/core/network/token_storage.dart';
import 'package:auto_hub_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_hub_app/features/splash/presentation/bloc/splash_state.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit responsible for initialization and determining the 
/// initial routing destination (Home, Onboarding, or Login).
@injectable
class SplashCubit extends Cubit<SplashState> {
  SplashCubit([
    this._authRepository,
    TokenStorage? tokenStorage,
  ])  : _tokenStorage = tokenStorage ?? (getIt.isRegistered<TokenStorage>() ? getIt<TokenStorage>() : null),
        super(const SplashState.initial());

  final AuthRepository? _authRepository;
  final TokenStorage? _tokenStorage;

  /// Initializes the application and determines the starting route.
  Future<void> initializeApp() async {
    // Artificial delay to satisfy splash visibility requirements.
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final storage = _tokenStorage;
    final repo = _authRepository;

    if (storage != null && !storage.isAuthenticated) {
      emit(SplashState.unauthenticated(
        isFirstTime: !storage.hasSeenOnboarding,
      ));
      return;
    }

    if (repo != null) {
      final sessionResult = await repo.getSession();
      sessionResult.fold(
        (failure) {
          if (failure is UnauthorizedFailure) {
            emit(SplashState.unauthenticated(
              isFirstTime: !(storage?.hasSeenOnboarding ?? false),
            ));
          } else {
            // Transient network failure or server error, but user has saved tokens:
            // Allow them to proceed to home/dashboard rather than kicking them out.
            emit(const SplashState.authenticated());
          }
        },
        (user) => emit(const SplashState.authenticated()),
      );
    } else {
      emit(const SplashState.unauthenticated(isFirstTime: true));
    }
  }
}
