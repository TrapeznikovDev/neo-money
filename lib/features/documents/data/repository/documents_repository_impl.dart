import 'package:dio/dio.dart';
import 'package:neomoney/core/network/api_client.dart';
import '../models/company_docs_model.dart';
import '../models/company_docs_response.dart';
import 'documents_repository.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final ApiClient _api;
  DocumentsRepositoryImpl(this._api);

  @override
  Future<CompanyDocsModel> fetchCompanyDocs() async {
    final Response<dynamic> res = await _api.get<dynamic>('v2/company_docs');
    final data = res.data;

    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected response type: ${data.runtimeType}');
    }

    final parsed = CompanyDocsResponse.fromJson(data);

    if (!parsed.success) {
      throw StateError('API returned success=false (status=${parsed.status})');
    }

    return parsed.data;
  }
}