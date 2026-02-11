import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_entity.freezed.dart';

@freezed
abstract class ChatEntity with _$ChatEntity {
  const factory ChatEntity({
    required String id,
    required String title,
    required String subtitle,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    @Default(0) int unreadCount,
    @Default(0) int memberCount,
  }) = _ChatEntity;
}

@freezed
abstract class GuideEntity with _$GuideEntity {
  const factory GuideEntity({
    required String id,
    required String name,
    required String role,
    String? avatarUrl,
  }) = _GuideEntity;
}

@freezed
abstract class ChatData with _$ChatData {
  const factory ChatData({
    ChatEntity? currentMission,
    @Default([]) List<GuideEntity> guides,
    @Default([]) List<ChatEntity> history,
  }) = _ChatData;
}

@freezed
abstract class GroupMemberEntity with _$GroupMemberEntity {
  const factory GroupMemberEntity({
    required String id,
    required String name,
    required String role,
    required bool isGuide,
    @Default(false) bool isMe,
    String? avatarUrl,
  }) = _GroupMemberEntity;
}

@freezed
abstract class GroupDetailEntity with _$GroupDetailEntity {
  const factory GroupDetailEntity({
    required List<GroupMemberEntity> members,
    required List<String> mediaUrls,
  }) = _GroupDetailEntity;
}
