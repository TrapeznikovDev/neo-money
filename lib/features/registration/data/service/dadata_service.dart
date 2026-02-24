import 'package:dio/dio.dart';
import 'package:neomoney/core/storage/constants.dart';
import 'package:neomoney/features/registration/data/models/city_suggestions.dart';
import 'package:neomoney/features/registration/data/models/company_model.dart';
import 'package:neomoney/features/registration/data/models/dadata_address.dart';
import 'package:neomoney/features/registration/data/models/dadata_unit.dart';
import 'package:neomoney/features/registration/data/models/region_suggestions.dart';
import 'package:neomoney/features/registration/data/models/streets_suggestions.dart';

class DadataNfService {
  final Dio _dio;

  DadataNfService()
      : _dio = Dio(
    BaseOptions(
      baseUrl: Constants.dadataUrl,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Token ${Constants.dadataToken}'},
    ),
  );

  Future<List<DadataFmsUnit>> issuedBy({required String code}) async {
    try {
      final res = await _dio.post('fms_unit', data: {'query': code});

      final list = res.data['suggestions'] as List;
      return list.map((e) => DadataFmsUnit.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('DaData fms_unit error: ${e.message}');
    }
  }

  Future<List<DadataAddress>> addressSuggestion({required String address}) async {
    try {
      final res = await _dio.post('address', data: {'query': address});

      final list = res.data['suggestions'] as List;
      return list.map((e) => DadataAddress.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception('DaData address error: ${e.message}');
    }
  }

  Future<List<CompanySuggestion>> fetchCompanies({required String query}) async {
    final res = await _dio.post('party', data: {'query': query});
    final map = (res.data as Map).cast<String, dynamic>();
    final parsed = CompaniesResponse.fromJson(map);

    return parsed.suggestions;
  }

  Future<List<RegionSuggestion>> suggestRegions({required String query}) async {
    final r = await _dio.post(
      'address',
      data: {
        'query': query,
        'from_bound': {'value': 'region'},
        'to_bound': {'value': 'region'},
      },
    );

    final list = (r.data['suggestions'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => RegionSuggestion.fromJson(e.cast<String, dynamic>()))
        .where((e) =>
    e.title
        .trim()
        .isNotEmpty)
        .toList();
  }

  Future<List<CitySuggestion>> suggestCities({
    required String query,
    required String regionFiasId,
  }) async {
    final r = await _dio.post(
      'address',
      data: {
        'query': query,
        'from_bound': {'value': 'city'},
        'to_bound': {'value': 'settlement'},
        'locations': [
          {'region_fias_id': regionFiasId}
        ],
      },
    );

    final list = (r.data['suggestions'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => CitySuggestion.fromJson(e.cast<String, dynamic>()))
        .where((e) =>
    e.title
        .trim()
        .isNotEmpty)
        .toList();
  }

  Future<List<StreetSuggestion>> suggestStreets({
    required String query,
    required String regionFiasId,
    required String localityFiasId,
  }) async {
    final r = await _dio.post(
      'address',
      data: {
        'query': query,
        'from_bound': {'value': 'street'},
        'to_bound': {'value': 'street'},
        'locations': [
          {
            'region_fias_id': regionFiasId,
            'city_fias_id': localityFiasId,
          }
        ],
      },
    );

    final list = (r.data['suggestions'] as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => StreetSuggestion.fromJson(e.cast<String, dynamic>()))
        .where((e) =>
    e.title
        .trim()
        .isNotEmpty)
        .toList();
  }
}
