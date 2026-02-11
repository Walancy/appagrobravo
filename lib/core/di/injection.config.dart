// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:agrobravo/core/di/register_module.dart' as _i145;
import 'package:agrobravo/features/auth/data/repositories/auth_repository_impl.dart'
    as _i450;
import 'package:agrobravo/features/auth/domain/repositories/auth_repository.dart'
    as _i1062;
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart'
    as _i681;
import 'package:agrobravo/features/chat/data/repositories/chat_repository_impl.dart'
    as _i175;
import 'package:agrobravo/features/chat/domain/repositories/chat_repository.dart'
    as _i135;
import 'package:agrobravo/features/chat/presentation/cubit/chat_cubit.dart'
    as _i178;
import 'package:agrobravo/features/chat/presentation/cubit/chat_detail_cubit.dart'
    as _i997;
import 'package:agrobravo/features/chat/presentation/cubit/group_info_cubit.dart'
    as _i958;
import 'package:agrobravo/features/documents/data/repositories/documents_repository_impl.dart'
    as _i641;
import 'package:agrobravo/features/documents/domain/repositories/documents_repository.dart'
    as _i194;
import 'package:agrobravo/features/documents/presentation/cubit/documents_cubit.dart'
    as _i920;
import 'package:agrobravo/features/home/data/repositories/feed_repository_impl.dart'
    as _i386;
import 'package:agrobravo/features/home/domain/repositories/feed_repository.dart'
    as _i1016;
import 'package:agrobravo/features/home/presentation/cubit/feed_cubit.dart'
    as _i700;
import 'package:agrobravo/features/itinerary/data/repositories/itinerary_repository_impl.dart'
    as _i758;
import 'package:agrobravo/features/itinerary/domain/repositories/itinerary_repository.dart'
    as _i889;
import 'package:agrobravo/features/itinerary/presentation/cubit/itinerary_cubit.dart'
    as _i934;
import 'package:agrobravo/features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i502;
import 'package:agrobravo/features/notifications/domain/repositories/notifications_repository.dart'
    as _i748;
import 'package:agrobravo/features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i692;
import 'package:agrobravo/features/profile/data/repositories/profile_repository_impl.dart'
    as _i586;
import 'package:agrobravo/features/profile/domain/repositories/profile_repository.dart'
    as _i321;
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart'
    as _i514;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i321.ProfileRepository>(
      () => _i586.ProfileRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i194.DocumentsRepository>(
      () => _i641.DocumentsRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i135.ChatRepository>(
      () => _i175.ChatRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1062.AuthRepository>(
      () => _i450.AuthRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1016.FeedRepository>(
      () => _i386.FeedRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i748.NotificationsRepository>(
      () => _i502.NotificationsRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i889.ItineraryRepository>(
      () => _i758.ItineraryRepositoryImpl(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i920.DocumentsCubit>(
      () => _i920.DocumentsCubit(gh<_i194.DocumentsRepository>()),
    );
    gh.factory<_i934.ItineraryCubit>(
      () => _i934.ItineraryCubit(gh<_i889.ItineraryRepository>()),
    );
    gh.factory<_i178.ChatCubit>(
      () => _i178.ChatCubit(gh<_i135.ChatRepository>()),
    );
    gh.factory<_i997.ChatDetailCubit>(
      () => _i997.ChatDetailCubit(gh<_i135.ChatRepository>()),
    );
    gh.factory<_i958.GroupInfoCubit>(
      () => _i958.GroupInfoCubit(gh<_i135.ChatRepository>()),
    );
    gh.lazySingleton<_i681.AuthCubit>(
      () => _i681.AuthCubit(gh<_i1062.AuthRepository>()),
    );
    gh.factory<_i700.FeedCubit>(
      () => _i700.FeedCubit(gh<_i1016.FeedRepository>()),
    );
    gh.factory<_i514.ProfileCubit>(
      () => _i514.ProfileCubit(
        gh<_i321.ProfileRepository>(),
        gh<_i1062.AuthRepository>(),
      ),
    );
    gh.factory<_i692.NotificationsCubit>(
      () => _i692.NotificationsCubit(gh<_i748.NotificationsRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i145.RegisterModule {}
