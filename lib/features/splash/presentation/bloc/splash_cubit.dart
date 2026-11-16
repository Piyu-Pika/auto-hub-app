import 'package:auto_hub_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_hub_app/features/splash/presentation/bloc/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit responsible for initialization and determining the 
/// initial routing destination (Home, Onboarding, or Login).
@injectable
class SplashCubit extends Cubit<SplashState> {
  SplashCubit([this._authRepository]) : super(const SplashState.initial());

  final AuthRepository? _authRepository;

  /// Initializes the application and determines the starting route.
  Future<void> initializeApp() async {
    // Artificial delay to satisfy splash visibility requirements.
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (_authRepository != null) {
      final sessionResult = await _authRepository.getSession();
      sessionResult.fold(
        (failure) => emit(const SplashState.unauthenticated(isFirstTime: false)),
        (user) => emit(const SplashState.authenticated()),
      );
    } else {
      emit(const SplashState.unauthenticated(isFirstTime: true));
    }
  }
}
