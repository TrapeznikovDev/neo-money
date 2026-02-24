import '../api/app_info_api.dart';
import '../dto/app_info_dto.dart';

class AppInfoRepository {
  final AppInfoApi _api;

  AppInfoRepository(this._api);

  Future<AppInfoDto> fetchAppInfo() => _api.appInfo();
}