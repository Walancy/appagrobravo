import 'package:dartz/dartz.dart';
import '../entities/itinerary_item.dart';
import '../entities/itinerary_group.dart';
import '../entities/emergency_contacts.dart';

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
  Future<Either<Exception, List<String>>> getUserPendingDocuments();
  Future<Either<Exception, EmergencyContacts>> getEmergencyContacts(
    double lat,
    double lng,
  );
}
