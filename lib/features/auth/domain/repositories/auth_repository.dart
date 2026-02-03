import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Exception, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Exception, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String userType, // 'USER_APP' or 'GUIA'
  });

  Future<void> signOut();

  Future<Option<UserEntity>> getCurrentUser();

  Future<Either<Exception, void>> resetPassword(String email);
}
