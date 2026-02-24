import 'package:dio/dio.dart';
import 'package:neomoney/features/home/screens/main/data/models/images_model.dart';
import 'package:neomoney/features/registration/data/models/bank_model.dart';
import 'package:neomoney/features/registration/data/models/check_light_flow_model.dart';
import 'package:neomoney/features/registration/data/models/loan_calc_model.dart';

abstract class RegistrationRepository {
  Future<void> requestSms(String phone);

  Future<void> confirmSms({required String phone, required String code});

  Future<void> submitStep1Fio({
    required String firstname,
    required String lastname,
    required String patronymic,
    required String birth,
    required String email,
  });

  Future<void> submitStep2Passport({
    required String birthPlace,
    required String gender,
    required String passportDate,
    required String passportIssued,
    required String passportSerial,
    required String passportSubdivisionCode,
  });

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
  });

  Future<void> uploadPhoto({required MultipartFile file, required String type});

  Future<void> submitStep6Work({
    required String place,
    required String adress,
    required String salary,
    required String profession,
    required String workScope,
  });

  Future<String> regPaymentUrlNf();

  Future<bool> sendFirstLoan({
    required int amount,
    required int period,
    required String cardId,
    required String creditDoctor,
    required String serviceInsurance,
    required String? complete,
  });

  Future<LoanCalcResult> fullAmountToBePaid({
    required int amount,
    required int term,
  });

  Future<NkLightFlowModel>checkNkLightFlowNf();

  Future<List<BankModel>> getSBPBankList();

  Future<void> selectSBPBank({int? bankId, int? orderId});

  Future<List<ImagesInfoModel>> fetchImages({bool? isReg});
}
