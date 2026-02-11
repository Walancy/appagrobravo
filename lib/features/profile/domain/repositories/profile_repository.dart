import 'package:dartz/dartz.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/home/domain/entities/post_entity.dart';

abstract class ProfileRepository {
  Future<Either<Exception, ProfileEntity>> getProfile(String userId);
  Future<Either<Exception, List<PostEntity>>> getUserPosts(String userId);
  Future<Either<Exception, String>> updateProfilePhoto(String filePath);
  Future<Either<Exception, String>> updateCoverPhoto(String filePath);
  Future<Either<Exception, List<ProfileEntity>>> getConnections(String userId);
  Future<Either<Exception, List<ProfileEntity>>> getRequests(String userId);
  Future<Either<Exception, void>> requestConnection(String userId);
  Future<Either<Exception, void>> cancelConnection(String userId);
  Future<Either<Exception, void>> acceptConnection(String userId);
  Future<Either<Exception, void>> rejectConnection(String userId);
  Future<Either<Exception, void>> removeConnection(String userId);
  Future<Either<Exception, void>> updateFoodPreferences(String preferences);
  Future<Either<Exception, void>> updateMedicalRestrictions(
    String restrictions,
  );
  Future<Either<Exception, void>> updateAccountData({
    required Map<String, dynamic> data,
  });
}
