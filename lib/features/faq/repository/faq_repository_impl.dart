import 'package:dio/dio.dart';
import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/features/faq/models/question_answer_model.dart';
import 'package:neomoney/features/faq/repository/faq_repository.dart';

class FaqRepositoryImpl implements FaqRepository {
  final ApiClient _api;

  FaqRepositoryImpl(this._api);

  @override
  Future<Map<String, List<QuestionAnswerModel>>> getQuestionsAnswers() async {
    try {
      final res = await _api.get<dynamic>('v3/get_faq', options: Options(extra: {'skip_site_id': true}));
      final data = res.data;

      if (data is! Map) {
        throw StateError('Unexpected FAQ response type: ${data.runtimeType}');
      }

      final Map<String, dynamic> root = Map<String, dynamic>.from(data as Map);

      final dynamic payload = root['data'] is Map ? root['data'] : root;

      if (payload is! Map) {
        throw StateError('Unexpected FAQ payload type: ${payload.runtimeType}');
      }

      final Map<String, dynamic> sectionsMap = Map<String, dynamic>.from(payload as Map);

      return sectionsMap.map((key, value) {
        if (value is! List) {
          throw StateError('FAQ section "$key" is not a list: ${value.runtimeType}');
        }

        final list = value.whereType<Map>().map((e) => QuestionAnswerModel.fromMap(Map<String, dynamic>.from(e))).toList(growable: false);

        return MapEntry(key.toString(), list);
      });
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
