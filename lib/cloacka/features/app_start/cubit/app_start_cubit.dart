import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:neomoney/cloacka/app/router/app_routes.dart';
import 'package:neomoney/cloacka/core/storage/app_info_storage.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/features/app_start/data/repo/app_info_repository.dart';

import 'app_start_state.dart';

class AppStartCubit extends Cubit<AppStartState> {
  final AppInfoRepository _repo;
  final AppInfoStorage _storage;
  final AppPrefs _prefs;

  AppStartCubit(this._repo, this._storage, this._prefs) : super(const AppStartInitial());

  Future<void> bootstrap() async {
    emit(const AppStartLoading());
    try {
      final info = await _repo.fetchAppInfo();

      await _storage.save(
        regPhone: info.regPhoneNumber,
        regCode: info.regSmsCode,
        authPhone: info.authPhoneNumber,
        authCode: info.authSmsCode,
        cloacaVersion: info.cloacaVersion,
        privacyPolicyUrl: info.privacyPolicyUrl,
        registrationOrganizationInfo: info.registrationOrganizationInfo,
      );

      final pkg = await PackageInfo.fromPlatform();
      final appFullVersion = '${pkg.version}+${pkg.buildNumber}';

      final serverVersion = (info.cloacaVersion ?? '').trim();
      final serverBuild = (info.cloacaBuildVersion ?? '').trim();
      final serverFullVersion = '$serverVersion+$serverBuild';

      final bool allowCloacaFlow =
          serverVersion.isNotEmpty && serverBuild.isNotEmpty && serverFullVersion == appFullVersion;

      // ✅ сохраняем флаг, чтобы роутер/онбординг мог понять режим
      await _prefs.setCloacaEnabled(allowCloacaFlow);

      // ✅ если онбординг не пройден — всегда ведём на общий onboarding
      if (!_prefs.onboardingDone) {
        emit(AppStartLoaded(info, AppRouteNames.onboarding));
        return;
      }

      final token = await getIt<TokenStorage>().readAccessToken();
      final bool authedMain = token != null && token.isNotEmpty;

      final String baseRoute = authedMain ? AppRouteNames.homeScreen : AppRouteNames.authScreen;

      final nextRoute = allowCloacaFlow ? _resolveCloacaRoute() : baseRoute;

      emit(AppStartLoaded(info, nextRoute));
    } catch (e, s) {
      debugPrint('bootstrap error: $e\n$s');
      emit(AppStartError(e.toString()));
    }
  }

  String _resolveCloacaRoute() {
    // onboarding сюда больше НЕ должен попадать (он уже пройден)
    return _prefs.isAuthorized ? AppRoutesCloacka.home : AppRoutesCloacka.auth;
  }
}
