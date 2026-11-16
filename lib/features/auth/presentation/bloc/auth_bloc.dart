import 'package:auto_hub_app/core/errors/failures.dart';
import 'package:auto_hub_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:auto_hub_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:auto_hub_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthSessionChecked>(_onSessionChecked);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthSocialSubmitted>(_onSocialSubmitted);
    on<AuthForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<AuthResetPasswordSubmitted>(_onResetPasswordSubmitted);
    on<AuthLogoutSubmitted>(_onLogoutSubmitted);
  }

  final AuthRepository _authRepository;

  Future<void> _onSessionChecked(
    AuthSessionChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying session...'));
    final result = await _authRepository.getSession();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in...'));
    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
      deviceId: event.deviceId,
    );

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (authResult) => emit(AuthAuthenticated(authResult.user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));
    final result = await _authRepository.register(
      fullName: event.fullName,
      email: event.email,
      password: event.password,
      phone: event.phone,
      deviceId: event.deviceId,
      platform: event.platform,
    );

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (authResult) => emit(AuthAuthenticated(authResult.user)),
    );
  }

  Future<void> _onSocialSubmitted(
    AuthSocialSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(message: 'Connecting with ${event.provider}...'));
    final result = await _authRepository.socialAuth(
      provider: event.provider,
      idToken: event.idToken,
      deviceId: event.deviceId,
    );

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (authResult) => emit(AuthAuthenticated(authResult.user)),
    );
  }

  Future<void> _onForgotPasswordSubmitted(
    AuthForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Sending password reset link...'));
    final result = await _authRepository.forgotPassword(event.email);

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (msg) => emit(AuthActionSuccess(msg)),
    );
  }

  Future<void> _onResetPasswordSubmitted(
    AuthResetPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Resetting password...'));
    final result = await _authRepository.resetPassword(
      token: event.token,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) => emit(_mapFailureToState(failure)),
      (msg) => emit(AuthActionSuccess(msg)),
    );
  }

  Future<void> _onLogoutSubmitted(
    AuthLogoutSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }

  AuthState _mapFailureToState(Failure failure) {
    if (failure is ValidationFailure) {
      return AuthError(
        message: failure.message,
        field: failure.field,
        statusCode: failure.statusCode,
      );
    }
    return AuthError(
      message: failure.message,
      statusCode: failure.statusCode,
    );
  }
}
