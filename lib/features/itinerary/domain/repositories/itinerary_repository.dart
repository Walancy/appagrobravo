import 'package:dartz/dartz.dart';
import '../entities/itinerary_item.dart';
import '../entities/itinerary_group.dart';

abstract class ItineraryRepository {
  Future<Either<Exception, ItineraryGroupEntity>> getGroupDetails(
    String groupId,
  );
  Future<Either<Exception, List<ItineraryItemEntity>>> getItinerary(
    String groupId,
  );
  Future<Either<Exception, List<Map<String, dynamic>>>> getTravelTimes(
    String groupId,
  );
  Future<Either<Exception, String?>> getUserGroupId();
}
