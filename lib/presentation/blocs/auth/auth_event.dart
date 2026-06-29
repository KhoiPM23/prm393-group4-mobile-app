import '../../../domain/entities/user_entity.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);
}

class AuthLogoutRequested extends AuthEvent {}
