import 'package:dio/dio.dart';
import 'package:neomoney/features/home/screens/main/data/models/images_model.dart';
import 'package:neomoney/features/registration/data/models/bank_model.dart';
import 'package:neomoney/features/registration/data/models/check_light_flow_model.dart';
import 'package:neomoney/features/registration/data/models/loan_calc_model.dart';
import 'package:neomoney/features/registration/data/models/registration_confirm_response.dart';

abstract class RegistrationApi {
  Future<void> sendPhone(String phone);

  Future<RegistrationConfirmResponse> confirmPhone({
    required String phone,
    required String code,
  });

  Future<void> step1Fio({
    required String firstname,
    required String lastname,
    required String patronymic,
    required String birth,
    required String password,
    required String email,
  });

  Future<void> step2Passport({
    required String birthPlace,
    required String gender,
    required String passportDate,
    required String passportIssued,
    required String passportSerial,
    required String passportSubdivisionCode,
  });

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
  });

  Future<void> uploadPhoto({
    required MultipartFile file,
    required String type,
  });

  Future<void> step6Work({
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

  Future<NkLightFlowModel> checkNkLightFlowNf();

  Future<List<BankModel>> getSBPBankList();
  Future<void> selectSBPBank({int? bankId, int? orderId});
  Future<List<ImagesInfoModel>> fetchImages({bool? isReg});
}