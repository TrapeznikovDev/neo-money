import 'dart:io';

import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/registration/data/models/city_suggestions.dart';
import 'package:neomoney/features/registration/data/models/company_model.dart';
import 'package:neomoney/features/registration/data/models/region_suggestions.dart';
import 'package:neomoney/features/registration/data/models/streets_suggestions.dart';

enum GenderUi { male, female }

enum RegStep { fio, passport, address, preapproved, photo, work, card }

class RegistrationFlowState implements UiState {
  // ===== Base UI state =====
  @override
  final UiStatus status;
  @override
  final String? errorMessage;

  // ===== Navigation =====
  final RegStep step;

  final List<RegStep> regSteps;
  final int currStep;

  // ===== Step: fio =====
  final String lastName;
  final String firstName;
  final String middleName;
  final DateTime? birthDate;
  final String email;
  final bool isAgreementAccepted;

  // ===== Step: passport =====
  final String passportSerial;
  final DateTime? passportIssueDate;
  final String passportSubdivisionCode;
  final String passportIssued;
  final String birthPlace;
  final GenderUi? gender;

  final bool isIssuedByLoading;
  final List<String> issuedBySuggestions;

  final bool isBirthPlaceLoading;
  final List<String> birthPlaceSuggestions;

  // ===== Step: address =====
  final String region;
  final String locality;
  final String street;
  final String house;
  final String building;
  final String flat;

  final bool isSameAddress;

  // suggestions: region
  final bool isRegionLoading;

  // suggestions: locality
  final bool isLocalityLoading;

  // suggestions: street
  final bool isStreetLoading;

  // ===== Step: photo =====
  final File? passportPhoto1;
  final File? passportPhoto2;

  final int preapprovedAmount;
  final int preapprovedPeriod;

  final int preapprovedTerm;
  final bool calcLoading;
  final String calcError;

  final int? fullAmountToBePaid;
  final double? percent;

  final bool isUploadingPassportPhoto1;
  final bool isUploadingPassportPhoto2;

  final String? uploadPhotoError;

  // ===== Step: work =====
  final String workPlace;
  final String workAddress;
  final String workSalary;

  /// выбрано из списка "Должность" (bottom sheet)
  final String? professionValue;

  /// быстрые переключатели: "Самозанятый"/"Пенсионер"
  final String? workScope;

  String? get effectiveWorkScope => workScope ?? professionValue;

  final bool isProfessionOpen; // показывать список
  final List<String> professionSuggestions; // в твоём случае это просто весь список (или фильтрованный)

  final bool isWorkPlaceLoading;
  final List<CompanySuggestion> workPlaceSuggestions;

  // address selection context
  final String? regionFiasId;
  final String? localityFiasId; // city/settlement fias
  final String? postalCode; // индекс (опционально)

  // suggestions typed
  final List<RegionSuggestion> regionSuggestions;
  final List<CitySuggestion> localitySuggestions;
  final List<StreetSuggestion> streetSuggestions;

  final String regRegion;
  final String regLocality;
  final String regStreet;
  final String regHouse;
  final String regBuilding;
  final String regFlat;

  final String? regRegionFiasId;
  final String? regLocalityFiasId;
  final String? regPostalCode;

  final bool isRegRegionLoading;
  final bool isRegLocalityLoading;
  final bool isRegStreetLoading;

  final List<RegionSuggestion> regRegionSuggestions;
  final List<CitySuggestion> regLocalitySuggestions;
  final List<StreetSuggestion> regStreetSuggestions;

  final String? paymentLink;
  final bool openPaymentWebView;

  const RegistrationFlowState({
    // ui
    this.status = UiStatus.initial,
    this.errorMessage,

    // nav
    this.step = RegStep.fio,

    this.regSteps = const [],
    this.currStep = 0,

    // fio
    this.lastName = '',
    this.firstName = '',
    this.middleName = '',
    this.birthDate,
    this.email = '',
    this.isAgreementAccepted = true,

    // passport
    this.passportSerial = '',
    this.passportIssueDate,
    this.passportSubdivisionCode = '',
    this.passportIssued = '',
    this.birthPlace = '',
    this.gender = GenderUi.male,

    this.isIssuedByLoading = false,
    this.issuedBySuggestions = const [],

    this.isBirthPlaceLoading = false,
    this.birthPlaceSuggestions = const [],

    // address
    this.region = '',
    this.locality = '',
    this.street = '',
    this.house = '',
    this.building = '',
    this.flat = '',

    this.isSameAddress = true,

    this.isRegionLoading = false,

    this.isLocalityLoading = false,

    this.isStreetLoading = false,

    // photo
    this.passportPhoto1,
    this.passportPhoto2,
    this.isUploadingPassportPhoto1 = false,
    this.isUploadingPassportPhoto2 = false,
    this.uploadPhotoError,

    this.workPlace = '',
    this.workAddress = '',
    this.workSalary = '',
    this.paymentLink,
    this.professionValue,
    this.workScope,
    this.isProfessionOpen = false,
    this.professionSuggestions = const [],
    this.isWorkPlaceLoading = false,
    this.workPlaceSuggestions = const [],
    this.regionFiasId,
    this.localityFiasId,
    this.postalCode,

    this.regionSuggestions = const [],
    this.localitySuggestions = const [],
    this.streetSuggestions = const [],

    this.regRegion = '',
    this.regLocality = '',
    this.regStreet = '',
    this.regHouse = '',
    this.regBuilding = '',
    this.regFlat = '',
    this.regRegionFiasId,
    this.regLocalityFiasId,
    this.regPostalCode,

    this.isRegRegionLoading = false,
    this.isRegLocalityLoading = false,
    this.isRegStreetLoading = false,
    this.openPaymentWebView = false,

    this.regRegionSuggestions = const [],
    this.regLocalitySuggestions = const [],
    this.regStreetSuggestions = const [],

    this.preapprovedAmount = 30000,
    this.preapprovedPeriod = 16,
    this.preapprovedTerm = 16,
    this.calcLoading = false,
    this.calcError = '',
    this.fullAmountToBePaid = 30000,
    this.percent = 0,
  });

  // ===== UI helpers =====
  int get totalSteps => regSteps.isEmpty ? RegStep.values.length : regSteps.length;
  int get stepIndex => regSteps.isEmpty ? step.index : currStep;

  bool get isLoading => status == UiStatus.loading;

  bool get hasError => status == UiStatus.failure && (errorMessage?.isNotEmpty ?? false);

  // ===== Navigation helpers =====
  RegStep get nextStep {
    if (regSteps.isEmpty) {
      final idx = step.index + 1;
      return idx >= RegStep.values.length ? step : RegStep.values[idx];
    }

    final next = currStep + 1;
    return next >= regSteps.length ? regSteps.last : regSteps[next];
  }

  // ===== Copy =====
  RegistrationFlowState copyWith({
    UiStatus? status,

    // errorMessage: три-состояния
    String? errorMessage,
    bool clearErrorMessage = false,

    RegStep? step,

    List<RegStep>? regSteps,
    int? currStep,
    bool clearRegSteps = false,

    // phone
    String? phoneDigits,
    bool? isSmsRequested,
    String? smsCode,
    int? resendSecondsLeft,

    // fio
    String? lastName,
    String? firstName,
    String? middleName,
    DateTime? birthDate,
    bool setBirthDateNull = false,
    String? email,
    bool? isAgreementAccepted,

    // passport
    String? passportSerial,
    DateTime? passportIssueDate,
    bool setPassportIssueDateNull = false,
    String? passportSubdivisionCode,
    String? passportIssued,
    String? birthPlace,
    GenderUi? gender,
    bool setGenderNull = false,

    bool? isIssuedByLoading,
    List<String>? issuedBySuggestions,

    bool? isBirthPlaceLoading,
    List<String>? birthPlaceSuggestions,

    // address
    String? region,
    String? locality,
    String? street,
    String? house,
    String? building,
    String? flat,
    bool? isSameAddress,

    bool? isRegionLoading,
    List<RegionSuggestion>? regionSuggestions,

    bool? isLocalityLoading,
    List<CitySuggestion>? localitySuggestions,

    bool? isStreetLoading,
    List<StreetSuggestion>? streetSuggestions,

    // photo
    File? passportPhoto1,
    bool setPassportPhoto1Null = false,
    File? passportPhoto2,
    bool setPassportPhoto2Null = false,

    bool? isUploadingPassportPhoto1,
    bool? isUploadingPassportPhoto2,

    // uploadPhotoError: три-состояния
    String? uploadPhotoError,
    bool clearUploadPhotoError = false,

    // work ✅ ДОБАВЛЕНО
    String? workPlace,
    String? workAddress,
    String? workSalary,
    String? professionValue,
    bool setProfessionValueNull = false,
    String? workScope,
    bool setWorkScopeNull = false,
    bool? isProfessionOpen,
    List<String>? professionSuggestions,
    bool? isWorkPlaceLoading,
    List<CompanySuggestion>? workPlaceSuggestions,
    String? regionFiasId,
    String? localityFiasId,
    String? postalCode,
    String? regRegion,
    String? regLocality,
    String? regStreet,
    String? regHouse,
    String? regBuilding,
    String? regFlat,

    String? regRegionFiasId,
    String? regLocalityFiasId,
    String? regPostalCode,

    bool? isRegRegionLoading,
    bool? isRegLocalityLoading,
    bool? isRegStreetLoading,

    List<RegionSuggestion>? regRegionSuggestions,
    List<CitySuggestion>? regLocalitySuggestions,
    List<StreetSuggestion>? regStreetSuggestions,

    String? paymentLink,
    bool? openPaymentWebView,
    int? preapprovedAmount,
    int? preapprovedPeriod,
    int? preapprovedTerm,
    bool? calcLoading,
    String? calcError,
    int? fullAmountToBePaid,
    double? percent,
  }) {
    return RegistrationFlowState(
      status: status ?? this.status,

      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),

      step: step ?? this.step,

      regSteps: clearRegSteps ? const [] : (regSteps ?? this.regSteps),
      currStep: currStep ?? this.currStep,

      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      birthDate: setBirthDateNull ? null : (birthDate ?? this.birthDate),
      email: email ?? this.email,
      isAgreementAccepted: isAgreementAccepted ?? this.isAgreementAccepted,

      passportSerial: passportSerial ?? this.passportSerial,
      passportIssueDate: setPassportIssueDateNull ? null : (passportIssueDate ?? this.passportIssueDate),
      passportSubdivisionCode: passportSubdivisionCode ?? this.passportSubdivisionCode,
      passportIssued: passportIssued ?? this.passportIssued,
      birthPlace: birthPlace ?? this.birthPlace,
      gender: setGenderNull ? null : (gender ?? this.gender),

      isIssuedByLoading: isIssuedByLoading ?? this.isIssuedByLoading,
      issuedBySuggestions: issuedBySuggestions ?? this.issuedBySuggestions,

      isBirthPlaceLoading: isBirthPlaceLoading ?? this.isBirthPlaceLoading,
      birthPlaceSuggestions: birthPlaceSuggestions ?? this.birthPlaceSuggestions,

      region: region ?? this.region,
      locality: locality ?? this.locality,
      street: street ?? this.street,
      house: house ?? this.house,
      building: building ?? this.building,
      flat: flat ?? this.flat,
      isSameAddress: isSameAddress ?? this.isSameAddress,

      isRegionLoading: isRegionLoading ?? this.isRegionLoading,
      regionSuggestions: regionSuggestions ?? this.regionSuggestions,

      isLocalityLoading: isLocalityLoading ?? this.isLocalityLoading,
      localitySuggestions: localitySuggestions ?? this.localitySuggestions,

      isStreetLoading: isStreetLoading ?? this.isStreetLoading,
      streetSuggestions: streetSuggestions ?? this.streetSuggestions,

      passportPhoto1: setPassportPhoto1Null ? null : (passportPhoto1 ?? this.passportPhoto1),
      passportPhoto2: setPassportPhoto2Null ? null : (passportPhoto2 ?? this.passportPhoto2),
      isUploadingPassportPhoto1: isUploadingPassportPhoto1 ?? this.isUploadingPassportPhoto1,
      isUploadingPassportPhoto2: isUploadingPassportPhoto2 ?? this.isUploadingPassportPhoto2,

      uploadPhotoError: clearUploadPhotoError ? null : (uploadPhotoError ?? this.uploadPhotoError),

      workPlace: workPlace ?? this.workPlace,
      workAddress: workAddress ?? this.workAddress,
      workSalary: workSalary ?? this.workSalary,
      professionValue: setProfessionValueNull ? null : (professionValue ?? this.professionValue),
      workScope: setWorkScopeNull ? null : (workScope ?? this.workScope),
      isProfessionOpen: isProfessionOpen ?? this.isProfessionOpen,
      professionSuggestions: professionSuggestions ?? this.professionSuggestions,
      isWorkPlaceLoading: isWorkPlaceLoading ?? this.isWorkPlaceLoading,
      workPlaceSuggestions: workPlaceSuggestions ?? this.workPlaceSuggestions,
      regionFiasId: regionFiasId ?? this.regionFiasId,
      localityFiasId: localityFiasId ?? this.localityFiasId,
      postalCode: postalCode ?? this.postalCode,
      regRegion: regRegion ?? this.regRegion,
      regLocality: regLocality ?? this.regLocality,
      regStreet: regStreet ?? this.regStreet,
      regHouse: regHouse ?? this.regHouse,
      regBuilding: regBuilding ?? this.regBuilding,
      regFlat: regFlat ?? this.regFlat,
      regRegionFiasId: regRegionFiasId ?? this.regRegionFiasId,
      regLocalityFiasId: regLocalityFiasId ?? this.regLocalityFiasId,
      regPostalCode: regPostalCode ?? this.regPostalCode,
      isRegRegionLoading: isRegRegionLoading ?? this.isRegRegionLoading,
      isRegLocalityLoading: isRegLocalityLoading ?? this.isRegLocalityLoading,
      isRegStreetLoading: isRegStreetLoading ?? this.isRegStreetLoading,
      regRegionSuggestions: regRegionSuggestions ?? this.regRegionSuggestions,
      regLocalitySuggestions: regLocalitySuggestions ?? this.regLocalitySuggestions,
      regStreetSuggestions: regStreetSuggestions ?? this.regStreetSuggestions,
      openPaymentWebView: openPaymentWebView ?? this.openPaymentWebView,
      paymentLink: paymentLink ?? this.paymentLink,
      preapprovedAmount: preapprovedAmount ?? this.preapprovedAmount,
      preapprovedPeriod: preapprovedPeriod ?? this.preapprovedPeriod,
      preapprovedTerm: preapprovedTerm ?? this.preapprovedTerm,
      calcLoading: calcLoading ?? this.calcLoading,
      calcError: calcError ?? this.calcError,
      fullAmountToBePaid: fullAmountToBePaid ?? this.fullAmountToBePaid,
      percent: percent ?? this.percent,
    );
  }

  static const initial = RegistrationFlowState();
}
