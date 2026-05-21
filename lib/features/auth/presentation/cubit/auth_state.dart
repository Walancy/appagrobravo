import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:agrobravo/features/auth/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.registrationSuccess({
    required String message,
    required bool needsEmailConfirmation,
  }) = _RegistrationSuccess;
  const factory AuthState.error(String message) = _Error;
  const factory AuthState.otpSent(String email) = _OtpSent;
  const factory AuthState.otpVerified() = _OtpVerified;
  const factory AuthState.passwordUpdated() = _PasswordUpdated;
}
