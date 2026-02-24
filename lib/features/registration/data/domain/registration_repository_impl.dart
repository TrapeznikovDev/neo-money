import 'package:dio/dio.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/features/home/screens/main/data/models/images_model.dart';
import 'package:neomoney/features/registration/data/domain/registration_repository.dart';
import 'package:neomoney/features/registration/data/models/bank_model.dart';
import 'package:neomoney/features/registration/data/models/check_light_flow_model.dart';
import 'package:neomoney/features/registration/data/models/loan_calc_model.dart';
import 'package:neomoney/features/registration/data/remote/registration_api.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationApi _api;
  final TokenStorage _tokenStorage;

  RegistrationRepositoryImpl(this._api, this._tokenStorage);

  @override
  Future<void> requestSms(String phone) {
    return _api.sendPhone(phone);
  }

  @override
  Future<void> confirmSms({required String phone, required String code}) async {
    final res = await _api.confirmPhone(phone: phone, code: code);

    await _tokenStorage.writeAccessToken(res.token);
  }

  @override
  Future<void> submitStep1Fio({
    required String firstname,
    required String lastname,
    required String patronymic,
    required String birth,
    required String email,
  }) {
    return _api.step1Fio(firstname: firstname, lastname: lastname, patronymic: patronymic, birth: birth, password: '11111111', email: email);
  }

  @override
  Future<void> submitStep2Passport({
    required String birthPlace,
    required String gender,
    required String passportDate,
    required String passportIssued,
    required String passportSerial,
    required String passportSubdivisionCode,
  }) async {
    return _api.step2Passport(
      birthPlace: birthPlace,
      gender: gender,
      passportDate: passportDate,
      passportIssued: passportIssued,
      passportSerial: passportSerial,
      passportSubdivisionCode: passportSubdivisionCode,
    );
  }

  @override
  Future<void> submitStep3Address({
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
    return _api.step3Address(
      faktRegion: faktRegion,
      faktCity: faktCity,
      faktStreet: faktStreet,
      faktHousing: faktHousing,
      faktBuilding: faktBuilding,
      faktRoom: faktRoom,
      faktIndex: faktIndex,

      regRegion: regRegion,
      regCity: regCity,
      regStreet: regStreet,
      regHousing: regHousing,
      regBuilding: regBuilding,
      regRoom: regRoom,
      regIndex: regIndex,

      regMatchesFact: regMatchesFact,
    );
  }

  @override
  Future<void> uploadPhoto({required MultipartFile file, required String type}) {
    return _api.uploadPhoto(file: file, type: type);
  }

  @override
  Future<void> submitStep6Work({
    required String place,
    required String adress,
    required String salary,
    required String profession,
    required String workScope,
  }) {
    return _api.step6Work(place: place, adress: adress, salary: salary, profession: profession, workScope: workScope);
  }

  @override
  Future<String> regPaymentUrlNf() {
    return _api.regPaymentUrlNf();
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

    return _api.sendFirstLoan(
      amount: amount,
      period: period,
      cardId: cardId,
      creditDoctor: creditDoctor,
      serviceInsurance: serviceInsurance,
      complete: complete,
    );
  }

  @override
  Future<LoanCalcResult> fullAmountToBePaid({required int amount, required int term}) {
    return _api.fullAmountToBePaid(amount: amount, term: term);
  }

  @override
  Future<NkLightFlowModel> checkNkLightFlowNf() async{
    return _api.checkNkLightFlowNf();
  }

  @override
  Future<List<BankModel>> getSBPBankList() {
    // TODO: implement getSBPBankList
    throw UnimplementedError();
  }

  @override
  Future<void> selectSBPBank({int? bankId, int? orderId}) {
    // TODO: implement selectSBPBank
    throw UnimplementedError();
  }

  @override
  Future<List<ImagesInfoModel>> fetchImages({bool? isReg}) {
    return _api.fetchImages(isReg: isReg);
  }
}
