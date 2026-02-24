import 'dart:developer';
import 'package:neomoney/core/network/api_client.dart';

import '../dto/app_info_dto.dart';

class AppInfoApi {
  final ApiClient _api;

  AppInfoApi(this._api);

  Future<AppInfoDto> appInfo() async {
    final res = await _api.get<dynamic>('app_info');
    final body = res.data;

    if (body is Map && body['data'] is Map) {
      final data = (body['data'] as Map).cast<String, dynamic>();
      log(data.toString());
      return AppInfoDto.fromJson(data);
    }

    throw StateError('Unexpected app_info response shape: ${body.runtimeType}');
  }
}