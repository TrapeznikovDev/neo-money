import 'package:dio/dio.dart';
import 'package:neomoney/core/network/api_client.dart';
import 'package:neomoney/features/home/screens/main/data/models/images_model.dart';
import 'package:neomoney/features/registration/data/models/bank_model.dart';
import 'package:neomoney/features/registration/data/models/check_light_flow_model.dart';
import 'package:neomoney/features/registration/data/models/loan_calc_model.dart';
import 'package:neomoney/features/registration/data/models/registration_confirm_response.dart';
import 'package:neomoney/features/registration/data/remote/registration_api.dart';

class RegistrationApiImpl implements RegistrationApi {
  final ApiClient _client;

  RegistrationApiImpl(this._client);

  @override
  Future<void> sendPhone(String phone) async {
    await _client.post('registration/by_phone', data: {'phone': phone});
    // если 200 — считаем успехом
  }

  @override
  Future<RegistrationConfirmResponse> confirmPhone({required String phone, required String code}) async {
    final res = await _client.post<Map<String, dynamic>>(
      'registration/by_phone_confirm',
      data: {'phone': phone, 'code': code, 'utm_term': 'app_ios'},
    );

    return RegistrationConfirmResponse.fromJson(res.data!);
  }

  @override
  Future<void> step1Fio({
    required String firstname,
    required String lastname,
    required String patronymic,
    required String birth,
    required String password,
    required String email,
  }) async {
    await _client.post(
      'registration/steps/1',
      data: {'firstname': firstname, 'lastname': lastname, 'patronymic': patronymic, 'birth': birth, 'password': password, 'email': email},
    );
  }

  @override
  Future<void> step2Passport({
    required String birthPlace,
    required String gender,
    required String passportDate,
    required String passportIssued,
    required String passportSerial,
    required String passportSubdivisionCode,
  }) {
    return _client.post(
      'registration/steps/2',
      data: {
        "birth_place": birthPlace,
        "gender": gender,
        "passport_date": passportDate,
        "passport_issued": passportIssued,
        "passport_serial": passportSerial,
        "passport_subdivision_code": passportSubdivisionCode,
      },
    );
  }

  @override
  Future<void> step3Address({
    required String faktRegion,
    required String faktCity,
    required String faktStreet,
    required String faktHousing,
    required String faktBuilding,
    required String faktRoom,
    required String faktIndex,

    required String regRegion,
    required String regCity,
    required String regStreet,
    required String regHousing,
    required String regBuilding,
    required String regRoom,
    required String regIndex,
    required bool regMatchesFact,
  }) {
    return _client.post(
      'registration/steps/3',
      data: {
        'faktregion': faktRegion,
        'faktcity': faktCity,
        'faktstreet': faktStreet,
        'fakthousing': faktHousing,
        'faktbuilding': faktBuilding,
        'faktroom': faktRoom,
        'faktindex': faktIndex,

        'regregion': regRegion,
        'regcity': regCity,
        'regstreet': regStreet,
        'reghousing': regHousing,
        'regbuilding': regBuilding,
        'regroom': regRoom,
        'regindex': regIndex,

        'reg_matches_fact': regMatchesFact,
      },
    );
  }

  @override
  Future<void> uploadPhoto({required MultipartFile file, required String type}) async {
    final formData = FormData.fromMap({'file': file, 'type': type});

    await _client.post('registration/step/upload_photo', data: formData);
  }

  @override
  Future<void> step6Work({
    required String place,
    required String adress,
    required String salary,
    required String profession,
    required String workScope,
  }) {
    return _client.post(
      'registration/steps/6',
      data: {
        "workregion": "",
        "workcity": "",
        "workstreet": "",
        "work_staff": salary,
        "workplace": place,
        "workindex": "",
        "workroom": "",
        "work_scope": workScope, //если выбрал самзанятого
        'profession': profession, //професиию если выбрал
        "workhousing": "",
        "work_address": adress,
      },
    );
  }

  @override
  Future<String> regPaymentUrlNf() async {
    final resp = await _client.get('registration/steps/4');

    final data = resp.data as Map<String, dynamic>;
    final link = (data['data'] as Map<String, dynamic>)['link'] as String?;

    if (link == null || link.trim().isEmpty) {
      throw Exception('Payment link is empty');
    }

    return link;
  }

  @override
  Future<bool> sendFirstLoan({
    required int amount,
    required int period,
    required String cardId,
    required String creditDoctor,
    required String serviceInsurance,
    required String? complete,
  }) async {
    final data = {"amount": amount, "period": period, "card_id": cardId, "credit_doctor": creditDoctor, "service_insurance": serviceInsurance};

    if (complete != null) {
      data["complete"] = complete;
    }

    final response = await _client.post('send_first_loan', data: data);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<LoanCalcResult> fullAmountToBePaid({required int amount, required int term}) async {
    final resp = await _client.get<Map<String, dynamic>>('v3/full_amount_to_be_paid', queryParameters: {'amount': amount, 'term': term});

    return LoanCalcResult.fromJson(resp.data!['data']);
  }

  @override
  Future<NkLightFlowModel> checkNkLightFlowNf() async {
    final response = await _client.get('v3/check_nk_light_flow');
    final data = response.data;
    final bool skipPhoto = data['skip_photo'] ?? false;
    final bool skipWork = data['skip_work'] ?? false;

    return NkLightFlowModel(skipPhoto: skipPhoto, skipWork: skipWork);
  }

  @override
  Future<List<BankModel>> getSBPBankList() async {
    final resp = await _client.get<Map<String, dynamic>>(
      'v3/get_sbp_bank_list',
    );

    final body = resp.data;
    if (body == null) {
      throw Exception('Empty response body');
    }

    final data = body['data'];

    if (data is List) {
      return data
          .map((e) => BankModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => BankModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Unexpected getSBPBankList response format: $body');
  }

  @override
  Future<void> selectSBPBank({int? bankId, int? orderId}) async {
    await _client.post(
      'v3/select_sbp_bank',
      data: {
        'bank_id': bankId,
        'order_id': orderId,
      },
    );
  }

  @override
  Future<List<ImagesInfoModel>> fetchImages({bool? isReg}) async{
    final response = await _client.get('images');

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => ImagesInfoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user images: ${response.statusCode}');
    }
  }
}
