import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:neomoney/cloacka/core/presentation/state/ui_state.dart';
import 'package:neomoney/cloacka/core/storage/app_info_storage.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/core/storage/planned_purchases_storage.dart';
import 'package:neomoney/cloacka/features/app_start/cubit/app_start_cubit.dart';
import 'package:neomoney/cloacka/features/app_start/data/api/app_info_api.dart';
import 'package:neomoney/cloacka/features/app_start/data/repo/app_info_repository.dart';
import 'package:neomoney/features/cards/data/cubit/cards_cubit.dart';
import 'package:neomoney/features/cards/data/repository/cards_repository.dart';
import 'package:neomoney/features/cards/data/repository/cards_repository_impl.dart';
import 'package:neomoney/features/chat/cubit/chat_cubit.dart';
import 'package:neomoney/features/chat/services/usedesk_chat_service.dart';
import 'package:neomoney/features/documents/data/cubit/documents_cubit.dart';
import 'package:neomoney/features/documents/data/repository/documents_repository.dart';
import 'package:neomoney/features/documents/data/repository/documents_repository_impl.dart';
import 'package:neomoney/features/faq/cubit/faq_cubit.dart';
import 'package:neomoney/features/faq/repository/faq_repository.dart';
import 'package:neomoney/features/faq/repository/faq_repository_impl.dart';
import 'package:neomoney/features/home/cubit/order_timer/order_cooling_down_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/accept_order_bloc/accept_order_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/fixation_bloc/payment_fixation_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/main_screen_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/promocode_bloc/promocode_cubit.dart';
import 'package:neomoney/features/home/screens/main/bloc/timer_auth_bloc/timer_auth_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/cubit/orders_cubit.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository_impl.dart';
import 'package:neomoney/features/home/screens/main/data/repository/promocode_repository.dart';
import 'package:neomoney/features/home/screens/main/data/repository/promocode_repository_impl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:neomoney/core/auth/secure_token_storage.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/core/network/dio_provider.dart';
import 'package:neomoney/core/network/singning/request_signer.dart';

import 'package:neomoney/features/auth/cubit/auth_cubit.dart';
import 'package:neomoney/features/auth/data/domain/auth_repository.dart';
import 'package:neomoney/features/auth/data/remote/auth_api.dart';
import 'package:neomoney/features/auth/data/auth_repository_impl.dart';
import 'package:neomoney/features/auth/data/remote/auth_api_impl.dart';

import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/data/domain/registration_repository.dart';
import 'package:neomoney/features/registration/data/domain/registration_repository_impl.dart';
import 'package:neomoney/features/registration/data/remote/registration_api.dart';
import 'package:neomoney/features/registration/data/remote/registration_api_impl.dart';
import 'package:neomoney/features/registration/data/service/dadata_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
    getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
  }

  // Token storage
  if (!getIt.isRegistered<TokenStorage>()) {
    getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  }

  // Signing
  if (!getIt.isRegistered<RequestSigner>()) {
    getIt.registerLazySingleton<RequestSigner>(() {
      const secretKey = 'удален';
      return Md5RequestSigner(secretKey: secretKey);
    });
  }

  // PackageInfo получаем синхронным singleton (получили асинхронно заранее)
  final pkg = await PackageInfo.fromPlatform();
  if (!getIt.isRegistered<PackageInfo>()) {
    getIt.registerSingleton<PackageInfo>(pkg);
  }

  // ApiClient — синхронный
  if (!getIt.isRegistered<ApiClient>()) {
    getIt.registerLazySingleton<ApiClient>(() {
      final provider = DioProvider(
        baseUrl: 'удален',
        tokenStorage: getIt<TokenStorage>(),
        signer: getIt<RequestSigner>(),
        versionProvider: () => '${pkg.version} (${pkg.buildNumber})',
        onUnauthorized: () {
          final navKey = getIt<GlobalKey<NavigatorState>>();
          final ctx = navKey.currentContext;
          if (ctx == null) return;

          Navigator.of(ctx).pushNamedAndRemoveUntil('/auth', (r) => false);
        },
        enableLogs: true,
      );
      return provider.createApiClient();
    });
  }

  if (!getIt.isRegistered<AuthApi>()) {
    getIt.registerLazySingleton<AuthApi>(() => AuthApiImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthApi>(), getIt<TokenStorage>()));
  }

  // Cubits
  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  }

  // ===== Registration =====
  getIt.registerLazySingleton<DadataNfService>(() => DadataNfService());

  if (!getIt.isRegistered<RegistrationApi>()) {
    getIt.registerLazySingleton<RegistrationApi>(() => RegistrationApiImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<RegistrationRepository>()) {
    getIt.registerLazySingleton<RegistrationRepository>(() => RegistrationRepositoryImpl(getIt<RegistrationApi>(), SecureTokenStorage()));
  }

  if (!getIt.isRegistered<RegistrationFlowCubit>()) {
    getIt.registerFactory<RegistrationFlowCubit>(
      () => RegistrationFlowCubit(getIt<RegistrationRepository>(), getIt<OrderRepository>(), DadataNfService(), SecureTokenStorage(), getIt<CardsRepository>()),
    );
  }

  getIt.registerFactory<MainTabCubit>(() => MainTabCubit());

  if (!getIt.isRegistered<DocumentsRepository>()) {
    getIt.registerLazySingleton<DocumentsRepository>(() => DocumentsRepositoryImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<DocumentsCubit>()) {
    getIt.registerFactory<DocumentsCubit>(() => DocumentsCubit(getIt<DocumentsRepository>()));
  }

  if (!getIt.isRegistered<CardsRepository>()) {
    getIt.registerLazySingleton<CardsRepository>(() => CardsRepositoryImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<CardsCubit>()) {
    getIt.registerFactory<CardsCubit>(() => CardsCubit(getIt<CardsRepository>()));
  }

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<AppPrefs>(AppPrefs(prefs));

  getIt.registerLazySingleton<AppState>(() => AppState(getIt<SharedPreferences>()));

  if (!getIt.isRegistered<AppInfoStorage>()) {
    getIt.registerLazySingleton<AppInfoStorage>(() => AppInfoStorage(getIt<SharedPreferences>()));
  }

  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: 'удален',
          headers: {'Accept': 'application/json'},
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      return dio;
    });
  }

  getIt.registerLazySingleton<AppInfoApi>(() => AppInfoApi(getIt<ApiClient>()));

  getIt.registerLazySingleton<AppInfoRepository>(() => AppInfoRepository(getIt<AppInfoApi>()));

  getIt.registerFactory<AppStartCubit>(() => AppStartCubit(getIt<AppInfoRepository>(), getIt<AppInfoStorage>(), getIt<AppPrefs>()));

  getIt.registerLazySingleton<PlannedPurchasesStorage>(() => PlannedPurchasesStorage(getIt<SharedPreferences>()));

  getIt.registerLazySingleton<UsedeskChatService>(() => UsedeskChatService());

  getIt.registerFactory<ChatCubit>(() => ChatCubit(getIt<UsedeskChatService>()));

  if (!getIt.isRegistered<OrderRepository>()) {
    getIt.registerLazySingleton<OrderRepository>(() => OrdersRepositoryImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<OrdersCubit>()) {
    getIt.registerFactory<OrdersCubit>(() => OrdersCubit(getIt<OrderRepository>(), SecureTokenStorage()));
  }

  if (!getIt.isRegistered<PaymentFixationCubit>()) {
    getIt.registerFactory<PaymentFixationCubit>(() => PaymentFixationCubit(getIt<OrderRepository>()));
  }

  if (!getIt.isRegistered<OrderCoolingDownCubit>()) {
    getIt.registerFactory<OrderCoolingDownCubit>(() => OrderCoolingDownCubit(getIt<OrderRepository>()));
  }

  if (!getIt.isRegistered<PromoCodeRepository>()) {
    getIt.registerLazySingleton<PromoCodeRepository>(() => PromoCodeRepositoryImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<PromoCodeCubit>()) {
    getIt.registerFactory<PromoCodeCubit>(() => PromoCodeCubit(getIt<PromoCodeRepository>()));
  }

  if (!getIt.isRegistered<AcceptOrderCubit>()) {
    getIt.registerFactory<AcceptOrderCubit>(() => AcceptOrderCubit(getIt<OrderRepository>()));
  }

  if (!getIt.isRegistered<TimerAuthCubit>()) {
    getIt.registerLazySingleton<TimerAuthCubit>(() => TimerAuthCubit());
  }

  if (!getIt.isRegistered<AcceptOrderCubit>()) {
    getIt.registerFactory<AcceptOrderCubit>(() => AcceptOrderCubit(getIt<OrderRepository>()));
  }
  if (!getIt.isRegistered<FaqRepository>()) {
    getIt.registerLazySingleton<FaqRepository>(() => FaqRepositoryImpl(getIt<ApiClient>()));
  }

  if (!getIt.isRegistered<FaqCubit>()) {
    getIt.registerFactory<FaqCubit>(() => FaqCubit(getIt<FaqRepository>()));
  }
}
