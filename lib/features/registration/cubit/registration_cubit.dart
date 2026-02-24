import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/features/cards/data/repository/cards_repository.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';
import 'package:neomoney/features/registration/data/models/check_light_flow_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:neomoney/core/auth/token_storage.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';
import 'package:neomoney/features/registration/data/domain/registration_repository.dart';
import 'package:neomoney/features/registration/data/models/city_suggestions.dart';
import 'package:neomoney/features/registration/data/models/company_model.dart';
import 'package:neomoney/features/registration/data/models/region_suggestions.dart';
import 'package:neomoney/features/registration/data/models/streets_suggestions.dart';
import 'package:neomoney/features/registration/data/service/dadata_service.dart';

class RegistrationFlowCubit extends Cubit<RegistrationFlowState> {
  final RegistrationRepository _repo;
  final CardsRepository _cardRepo;
  final OrderRepository _orderRepo;
  final DadataNfService _dadata;
  Timer? _issuedByDebounce;
  Timer? _birthPlaceDebounce;
  Timer? _regionDebounce;
  Timer? _localityDebounce;
  Timer? _streetDebounce;
  Timer? _workPlaceDebounce;
  Timer? _regRegionDebounce;
  Timer? _regLocalityDebounce;
  Timer? _regStreetDebounce;
  final ImagePicker _picker = ImagePicker();
  final TokenStorage _tokenStorage;

  RegistrationFlowCubit(this._repo, this._orderRepo, this._dadata, this._tokenStorage, this._cardRepo) : super(const RegistrationFlowState());

  // ======================
  // Step: phone
  // ======================

  Future<void> checkUserInfoAndRoute({bool isLoanNotSent = false}) async {
    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));

    try {
      // 1) light-flow
      NkLightFlowModel flow;
      try {
        flow = await _repo.checkNkLightFlowNf();
      } catch (_) {
        flow = NkLightFlowModel.disabled(); // как в boostra
      }

      // 2) user + cards + images
      final user = await _orderRepo.getUser();
      final cards = await _orderRepo.getCards(); // если у тебя так же как в OrdersCubit
      final images = await _repo.fetchImages();  // добавь в RegistrationRepository как в boostra

      final steps = <RegStep>[];

      // ---- fio
      final fioMissing =
          (user.firstname?.isEmpty ?? true) ||
              (user.lastname?.isEmpty ?? true) ||
              (user.patronymic?.isEmpty ?? true) ||
              (user.birth?.isEmpty ?? true);

      if (fioMissing) steps.add(RegStep.fio);

      // ---- passport
      final passportMissing =
          (user.passportSerial?.isEmpty ?? true) ||
              (user.passportDate?.isEmpty ?? true) ||
              (user.subdivisionCode?.isEmpty ?? true) ||
              (user.passportIssued?.isEmpty ?? true) ||
              (user.gender?.isEmpty ?? true) ||
              (user.birthPlace?.isEmpty ?? true);

      if (passportMissing) steps.add(RegStep.passport);

      // ---- address
      final addressMissing =
          (user.Regregion?.isEmpty ?? true) ||
              (user.Regcity?.isEmpty ?? true);

      if (addressMissing) steps.add(RegStep.address);

      // ---- preapproved (если надо форсить этот шаг)
      if (isLoanNotSent) steps.add(RegStep.preapproved);

      // ---- photo
      final hasValidPassport1 = images.any((img) =>
      img.type == 'passport1' && (img.status == 1 || img.status == 2));

      if (!flow.skipPhoto && !hasValidPassport1) {
        steps.add(RegStep.photo);
      }

      // ---- work (учёт Самозанятый/Пенсионер)
      if (!flow.skipWork) {
        final workScope = (user.workScope ?? '').trim();
        final isSpecial = workScope == 'Самозанятый' || workScope == 'Пенсионер';

        final noIncome = (user.incomeBase?.isEmpty ?? true);
        final noWorkplace = (user.workplace?.isEmpty ?? true);
        final noProfession = (user.profession?.isEmpty ?? true);
        final noWorkScope = workScope.isEmpty;

        bool needWork;
        if (isSpecial) {
          // спец-категории: важен только доход (и сам workScope уже есть на бэке)
          needWork = noIncome;
        } else {
          // обычный сценарий: место работы + доход + (profession или workScope)
          needWork = noWorkplace || noIncome || (noProfession && noWorkScope);
        }

        if (needWork) steps.add(RegStep.work);
      }

      // ---- card
      if (cards.isEmpty) {
        steps.add(RegStep.card);
      }

      if (steps.isEmpty) {
        // всё заполнено
        emit(state.copyWith(
          status: UiStatus.initial,
          clearRegSteps: true,
        ));
        return;
      }

      emit(state.copyWith(
        status: UiStatus.initial,
        regSteps: steps,
        currStep: 0,
        step: steps.first,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UiStatus.failure,
        errorMessage: 'Не удалось определить шаг регистрации: $e',
      ));
    }
  }

  void debugGoToStep(RegStep step) {
    emit(state.copyWith(step: step, status: UiStatus.initial, errorMessage: null));
  }

  void onNextPressed() {
    switch (state.step) {
      case RegStep.fio:
        submitStep1FioAndNext();
        return;

      case RegStep.passport:
        submitStep2PassportAndNext();
        return;

      case RegStep.address:
        submitStep3AddressAndNext();
        return;

      case RegStep.preapproved:
        submitPreapprovedAndRoute();
        return;

      case RegStep.photo:
        goNextStepInQueue();
        return;

      case RegStep.work:
        submitStep6WorkAndNext();
        return;

      case RegStep.card:
        requestPaymentLink();
        return;
    }
  }
  void debugNextStep() {
    final idx = state.step.index + 1;
    if (idx >= RegStep.values.length) return;
    debugGoToStep(RegStep.values[idx]);
  }

  Future<void> abortRegistrationAndClearToken() async {
    try {
      await _tokenStorage.clear();
    } catch (_) {}
    emit(const RegistrationFlowState());
  }

  void prev() {
    final prevIndex = state.step.index - 1;
    if (prevIndex < 0) return;

    emit(state.copyWith(step: RegStep.values[prevIndex]));
  }

  void regPhoneChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final phone = digits.length == 10 ? '7$digits' : digits;

    emit(state.copyWith(phoneDigits: phone, status: UiStatus.initial, errorMessage: null));
  }

  void regSmsChanged(String value) {
    emit(state.copyWith(smsCode: value, status: UiStatus.initial, errorMessage: null));
  }

  void lastNameChanged(String v) => emit(state.copyWith(lastName: v, status: UiStatus.initial, errorMessage: null));

  void firstNameChanged(String v) => emit(state.copyWith(firstName: v, status: UiStatus.initial, errorMessage: null));

  void middleNameChanged(String v) => emit(state.copyWith(middleName: v, status: UiStatus.initial, errorMessage: null));

  void birthDateChanged(DateTime d) => emit(state.copyWith(birthDate: d, status: UiStatus.initial, errorMessage: null));

  void emailChanged(String v) => emit(state.copyWith(email: v, status: UiStatus.initial, errorMessage: null));

  void agreementChanged(bool v) => emit(state.copyWith(isAgreementAccepted: v, status: UiStatus.initial, errorMessage: null));

  Future<void> submitStep1FioAndNext() async {
    // минимальная валидация
    if (state.lastName.trim().isEmpty || state.firstName.trim().isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Заполните ФИО'));
      return;
    }
    if (!state.isAgreementAccepted) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Нужно согласие на обработку данных'));
      return;
    }
    if (state.birthDate == null) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Выберите дату рождения'));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));
    try {
      final birth = DateFormat('dd.MM.yyyy').format(state.birthDate!);

      await _repo.submitStep1Fio(
        firstname: state.firstName.trim(),
        lastname: state.lastName.trim(),
        patronymic: state.middleName.trim(),
        birth: birth,
        email: state.email.trim(),
      );

      emit(state.copyWith(status: UiStatus.initial, clearErrorMessage: true));
      goNextStepInQueue();
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось отправить данные'));
    }
  }

  // ======================
  // Step: passport (НОВОЕ)
  // ======================

  void passportSerialChanged(String v) => emit(state.copyWith(passportSerial: v, status: UiStatus.initial, errorMessage: null));

  void passportIssueDateChanged(DateTime d) => emit(state.copyWith(passportIssueDate: d, status: UiStatus.initial, errorMessage: null));

  void genderChanged(GenderUi g) => emit(state.copyWith(gender: g, status: UiStatus.initial, errorMessage: null));

  String _genderToApi(GenderUi g) => g == GenderUi.male ? 'male' : 'female';

  Future<void> submitStep2PassportAndNext() async {
    if (state.passportSerial.trim().isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите серию и номер паспорта'));
      return;
    }
    if (state.passportIssueDate == null) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Выберите дату выдачи'));
      return;
    }
    if (state.passportSubdivisionCode.trim().isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите код подразделения'));
      return;
    }
    if (state.passportIssued.trim().isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите кем выдан паспорт'));
      return;
    }
    if (state.birthPlace.trim().isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите место рождения'));
      return;
    }
    if (state.gender == null) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Выберите пол'));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final passportDate = DateFormat('dd.MM.yyyy').format(state.passportIssueDate!);

      await _repo.submitStep2Passport(
        birthPlace: state.birthPlace.trim(),
        gender: _genderToApi(state.gender!),
        passportDate: passportDate,
        passportIssued: state.passportIssued.trim(),
        passportSerial: state.passportSerial.trim(),
        passportSubdivisionCode: state.passportSubdivisionCode.trim(),
      );

      emit(state.copyWith(status: UiStatus.initial, clearErrorMessage: true));
      goNextStepInQueue();
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось отправить паспортные данные'));
    }
  }

  void birthPlaceChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(birthPlace: v, status: UiStatus.initial, errorMessage: null));

    // меньше 3 символов — скрываем подсказки
    if (q.length < 3) {
      _birthPlaceDebounce?.cancel();
      emit(state.copyWith(isBirthPlaceLoading: false, birthPlaceSuggestions: const []));
      return;
    }

    _birthPlaceDebounce?.cancel();
    _birthPlaceDebounce = Timer(const Duration(milliseconds: 300), () async {
      await _loadBirthPlaceSuggestions(query: q);
    });
  }

  Future<void> _loadBirthPlaceSuggestions({required String query}) async {
    emit(state.copyWith(isBirthPlaceLoading: true));

    try {
      final res = await _dadata.addressSuggestion(address: query);

      final items = res.map((e) => e.value).where((s) => s.trim().isNotEmpty).toSet().toList();

      if (isClosed) return;
      emit(state.copyWith(isBirthPlaceLoading: false, birthPlaceSuggestions: items));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isBirthPlaceLoading: false, birthPlaceSuggestions: const []));
    }
  }

  void birthPlaceSelected(String value) {
    emit(
      state.copyWith(birthPlace: value, birthPlaceSuggestions: const [], isBirthPlaceLoading: false, status: UiStatus.initial, errorMessage: null),
    );
  }

  void regionChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(region: v, status: UiStatus.initial, clearErrorMessage: true));

    _regionDebounce?.cancel();

    if (q.length < 3) {
      emit(state.copyWith(isRegionLoading: false, regionSuggestions: const []));
      return;
    }

    _regionDebounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isRegionLoading: true));
      try {
        final items = await _dadata.suggestRegions(query: q);
        if (isClosed) return;
        emit(state.copyWith(isRegionLoading: false, regionSuggestions: items));
      } catch (_) {
        if (isClosed) return;
        emit(state.copyWith(isRegionLoading: false, regionSuggestions: const []));
      }
    });
  }

  void regionSelected(RegionSuggestion s) {
    emit(
      state.copyWith(
        region: s.title,
        regionFiasId: s.fiasId,
        postalCode: s.postalCode,
        locality: '',
        localityFiasId: null,
        street: '',
        house: '',
        building: '',
        flat: '',

        isRegionLoading: false,
        regionSuggestions: const [],
        isLocalityLoading: false,
        localitySuggestions: const [],
        isStreetLoading: false,
        streetSuggestions: const [],
      ),
    );
  }

  void localityChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(locality: v, status: UiStatus.initial, clearErrorMessage: true));

    _localityDebounce?.cancel();

    final regionFias = state.regionFiasId;
    if (regionFias == null || regionFias.isEmpty) {
      emit(state.copyWith(isLocalityLoading: false, localitySuggestions: const []));
      return;
    }

    if (q.length < 3) {
      emit(state.copyWith(isLocalityLoading: false, localitySuggestions: const []));
      return;
    }

    _localityDebounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isLocalityLoading: true));
      try {
        final items = await _dadata.suggestCities(query: q, regionFiasId: regionFias);
        if (isClosed) return;
        emit(state.copyWith(isLocalityLoading: false, localitySuggestions: items));
      } catch (_) {
        if (isClosed) return;
        emit(state.copyWith(isLocalityLoading: false, localitySuggestions: const []));
      }
    });
  }

  void localitySelected(CitySuggestion s) {
    emit(
      state.copyWith(
        locality: s.title,
        localityFiasId: s.fiasId,
        postalCode: s.postalCode ?? state.postalCode,

        // сбрасываем улицу и ниже
        street: '',
        house: '',
        building: '',
        flat: '',

        isLocalityLoading: false,
        localitySuggestions: const [],
        isStreetLoading: false,
        streetSuggestions: const [],
      ),
    );
  }

  void streetChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(street: v, status: UiStatus.initial, clearErrorMessage: true));

    _streetDebounce?.cancel();

    final regionFias = state.regionFiasId;
    final localityFias = state.localityFiasId;

    // без региона/города улицы не ищем
    if (regionFias == null || localityFias == null) {
      emit(state.copyWith(isStreetLoading: false, streetSuggestions: const []));
      return;
    }

    if (q.length < 3) {
      emit(state.copyWith(isStreetLoading: false, streetSuggestions: const []));
      return;
    }

    _streetDebounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isStreetLoading: true));
      try {
        final items = await _dadata.suggestStreets(query: q, regionFiasId: regionFias, localityFiasId: localityFias);
        if (isClosed) return;
        emit(state.copyWith(isStreetLoading: false, streetSuggestions: items));
      } catch (_) {
        if (isClosed) return;
        emit(state.copyWith(isStreetLoading: false, streetSuggestions: const []));
      }
    });
  }

  void streetSelected(StreetSuggestion s) {
    emit(state.copyWith(street: s.title, isStreetLoading: false, streetSuggestions: const []));
  }

  void sameAddressChanged(bool v) {
    if (v) {
      emit(
        state.copyWith(
          isSameAddress: true,

          regRegion: state.region,
          regRegionFiasId: state.regionFiasId,
          regLocality: state.locality,
          regLocalityFiasId: state.localityFiasId,
          regStreet: state.street,
          regHouse: state.house,
          regBuilding: state.building,
          regFlat: state.flat,
          regPostalCode: state.postalCode,

          // закрываем подсказки регистрации
          isRegRegionLoading: false,
          isRegLocalityLoading: false,
          isRegStreetLoading: false,
          regRegionSuggestions: const [],
          regLocalitySuggestions: const [],
          regStreetSuggestions: const [],
        ),
      );
    } else {
      emit(state.copyWith(isSameAddress: false));
    }
  }

  void houseChanged(String v) => emit(state.copyWith(house: v, status: UiStatus.initial, clearErrorMessage: true));

  void buildingChanged(String v) => emit(state.copyWith(building: v, status: UiStatus.initial, clearErrorMessage: true));

  void flatChanged(String v) => emit(state.copyWith(flat: v, status: UiStatus.initial, clearErrorMessage: true));

  void regHouseChanged(String v) => emit(state.copyWith(regHouse: v, status: UiStatus.initial, clearErrorMessage: true));

  void regBuildingChanged(String v) => emit(state.copyWith(regBuilding: v, status: UiStatus.initial, clearErrorMessage: true));

  void regFlatChanged(String v) => emit(state.copyWith(regFlat: v, status: UiStatus.initial, clearErrorMessage: true));

  void preapprovedTermChanged(int value) {
    emit(state.copyWith(preapprovedTerm: value));
  }

  Future<void> fetchLoanCalc() async {
    try {
      emit(state.copyWith(calcLoading: true, calcError: ''));

      final res = await _repo.fullAmountToBePaid(amount: state.preapprovedAmount, term: state.preapprovedTerm);

      emit(state.copyWith(calcLoading: false, calcError: '', fullAmountToBePaid: res.fullAmountToBePaid, percent: res.percent));
    } catch (e) {
      emit(
        state.copyWith(
          calcLoading: false,
          calcError: e.toString(),
        ),
      );
    }
  }

  Future<void> submitPreapprovedAndRoute() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      // 1) Отправляем заявку
      final ok = await _repo.sendFirstLoan(
        amount: state.preapprovedAmount,
        period: state.preapprovedPeriod,
        cardId: '0',
        creditDoctor: '1',
        serviceInsurance: '1',
        complete: '0',
      );

      if (!ok) {
        emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось отправить заявку'));
        return;
      }

      // 2) Узнаём настройки light-flow
      final flow = await _repo.checkNkLightFlowNf();

      // 3) Выбираем следующий шаг
      final next = _nextAfterPreapproved(flow);

      emit(state.copyWith(status: UiStatus.initial, step: next));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }

  void preapprovedAmountChanged(int value) {
    emit(state.copyWith(preapprovedAmount: value, status: UiStatus.initial, errorMessage: null));
  }

  void preapprovedPeriodChanged(int value) {
    emit(state.copyWith(preapprovedPeriod: value, status: UiStatus.initial, errorMessage: null));
  }

  Future<void> submitStep3AddressAndNext() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final same = state.isSameAddress;

      final regRegion = same ? state.region : state.regRegion;
      final regCity = same ? state.locality : state.regLocality;
      final regStreet = same ? state.street : state.regStreet;
      final regHouse = same ? state.house : state.regHouse;
      final regBuild = same ? state.building : state.regBuilding;
      final regFlat = same ? state.flat : state.regFlat;

      await _repo.submitStep3Address(
        // фактический адрес
        faktRegion: state.region,
        faktCity: state.locality,
        faktStreet: state.street,
        faktHousing: state.house,
        faktBuilding: state.building,
        faktRoom: state.flat,
        faktIndex: state.postalCode ?? '',

        // адрес регистрации (если same==true — копия фактического)
        regRegion: regRegion,
        regCity: regCity,
        regStreet: regStreet,
        regHousing: regHouse,
        regBuilding: regBuild,
        regRoom: regFlat,
        regIndex: same ? (state.postalCode ?? '') : (state.regPostalCode ?? ''),

        regMatchesFact: same,
      );

      emit(state.copyWith(status: UiStatus.initial, clearErrorMessage: true));
      goNextStepInQueue();
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось сохранить адрес'));
    }
  }

  RegStep _nextAfterPreapproved(NkLightFlowModel flow) {
    if (flow.skipPhoto && flow.skipWork) return RegStep.card;
    if (flow.skipPhoto) return RegStep.work;
    if (flow.skipWork) return RegStep.card;
    return RegStep.photo;
  }

  // ======================
  // next() роутит логику по шагам
  // ======================
  void goNextStepInQueue() {
    if (state.regSteps.isEmpty) {
      emit(state.copyWith(step: state.nextStep));
      return;
    }

    final nextIndex = state.currStep + 1;
    if (nextIndex >= state.regSteps.length) return;

    emit(state.copyWith(
      currStep: nextIndex,
      step: state.regSteps[nextIndex],
      status: UiStatus.initial,
      clearErrorMessage: true,
    ));
  }

  @override
  Future<void> close() {
    _regionDebounce?.cancel();
    _localityDebounce?.cancel();
    _streetDebounce?.cancel();
    _issuedByDebounce?.cancel();
    _birthPlaceDebounce?.cancel();
    _workPlaceDebounce?.cancel();
    _regRegionDebounce?.cancel();
    _regLocalityDebounce?.cancel();
    _regStreetDebounce?.cancel();
    return super.close();
  }

  void passportSubdivisionCodeChanged(String v) {
    emit(state.copyWith(passportSubdivisionCode: v, status: UiStatus.initial, errorMessage: null));

    if (v.length < 7) {
      // "123-456"
      _issuedByDebounce?.cancel();
      emit(state.copyWith(issuedBySuggestions: const [], isIssuedByLoading: false));
      return;
    }

    _issuedByDebounce?.cancel();
    _issuedByDebounce = Timer(const Duration(milliseconds: 300), () async {
      await _loadIssuedBySuggestions(code: v);
    });
  }

  Future<void> _loadIssuedBySuggestions({required String code}) async {
    emit(state.copyWith(isIssuedByLoading: true));

    try {
      final res = await _dadata.issuedBy(code: code);

      final items = res.map((e) => e.name).where((s) => s.trim().isNotEmpty).toSet().toList();

      if (isClosed) return;
      emit(state.copyWith(isIssuedByLoading: false, issuedBySuggestions: items));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isIssuedByLoading: false, issuedBySuggestions: const []));
    }
  }

  void issuedBySelected(String value) {
    emit(
      state.copyWith(passportIssued: value, issuedBySuggestions: const [], isIssuedByLoading: false, status: UiStatus.initial, errorMessage: null),
    );
  }

  void passportIssuedChanged(String v) {
    emit(state.copyWith(passportIssued: v, status: UiStatus.initial, errorMessage: null));
  }

  Future<void> pickPassportPhoto1FromGallery() => _pickAndUploadPassport(slot: 1, source: ImageSource.gallery);

  Future<void> pickPassportPhoto1FromCamera() => _pickAndUploadPassport(slot: 1, source: ImageSource.camera);

  Future<void> _pickAndUploadPassport({required int slot, required ImageSource source}) async {
    try {
      emit(state.copyWith(uploadPhotoError: null));

      final picked = await _picker.pickImage(
        source: source,
        // НЕ ставим imageQuality — у тебя отдельная компрессия по размеру
        // maxWidth / maxHeight можно добавить при желании:
        // maxWidth: 2000,
      );

      if (picked == null) return;

      final originalFile = File(picked.path);

      if (!_isValidMimeType(originalFile.path)) {
        emit(state.copyWith(uploadPhotoError: 'Неподдерживаемый формат файла'));
        return;
      }

      // показываем локально сразу (опционально) или после компрессии
      // я покажу после компрессии (логичнее по факту отправляемого файла)

      // флаг загрузки
      emit(
        state.copyWith(
          isUploadingPassportPhoto1: slot == 1 ? true : state.isUploadingPassportPhoto1,
          isUploadingPassportPhoto2: slot == 2 ? true : state.isUploadingPassportPhoto2,
        ),
      );

      final compressed = await _handleImage(originalFile);
      if (compressed == null) {
        emit(state.copyWith(uploadPhotoError: 'Не удалось обработать изображение'));
        return;
      }

      final fileName = compressed.uri.pathSegments.isNotEmpty ? compressed.uri.pathSegments.last : 'photo.jpg';

      final multipart = await MultipartFile.fromFile(compressed.path, filename: fileName);

      final type = slot == 1 ? 'pasport1' : 'pasport2';

      await _repo.uploadPhoto(file: multipart, type: type);

      // сохраняем в стейт локальный файл для отображения
      emit(
        state.copyWith(passportPhoto1: slot == 1 ? compressed : state.passportPhoto1, passportPhoto2: slot == 2 ? compressed : state.passportPhoto2),
      );
    } catch (e) {
      emit(state.copyWith(uploadPhotoError: 'Ошибка загрузки фото'));
    } finally {
      if (isClosed) return;
      emit(
        state.copyWith(
          isUploadingPassportPhoto1: slot == 1 ? false : state.isUploadingPassportPhoto1,
          isUploadingPassportPhoto2: slot == 2 ? false : state.isUploadingPassportPhoto2,
        ),
      );
    }
  }

  bool _isValidMimeType(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png') || p.endsWith('.heic') || p.endsWith('.heif');
  }

  Future<File?> _handleImage(File pickedFile) async {
    final file = File(pickedFile.path);

    if (!_isValidMimeType(file.path)) {
      throw Exception("Неподдерживаемый MIME-тип");
    }

    final compressedFile = await _compressImage(file, 90);
    return compressedFile;
  }

  Future<File?> _compressImage(File file, int quality) async {
    // safety
    if (quality < 30) quality = 30;

    final dir = await getTemporaryDirectory();
    final outPath = '${dir.path}/passport_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final bytes = await FlutterImageCompress.compressWithFile(file.absolute.path, quality: quality, format: CompressFormat.jpeg);

    if (bytes == null) return null;

    if (bytes.lengthInBytes > 1900000 && quality > 30) {
      return _compressImage(file, quality - 10);
    }

    final outFile = File(outPath);
    await outFile.writeAsBytes(bytes, flush: true);
    return outFile;
  }

  static const professionList = <String>[
    'Работаю официально',
    'Государственный служащий',
    'Муниципальный служащий',
    'Индивидуальный предприниматель',
    'Собственник бизнеса',
    'Работаю неофициально',
    'Студент',
    'Не работаю',
  ];

  void workAddressChanged(String v) => emit(state.copyWith(workAddress: v, status: UiStatus.initial, errorMessage: null));

  void workSalaryChanged(String v) => emit(state.copyWith(workSalary: v, status: UiStatus.initial, errorMessage: null));

  Future<void> submitStep6WorkAndNext() async {
    final isSpecialScope = state.workScope == 'Самозанятый' || state.workScope == 'Пенсионер';

    final salary = state.workSalary.replaceAll(RegExp(r'\D'), '').trim();
    if (salary.isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите доход в месяц'));
      return;
    }

    // special: только workScope + salary
    if (isSpecialScope) {
      emit(state.copyWith(status: UiStatus.loading, errorMessage: null));
      try {
        await _repo.submitStep6Work(place: '', adress: '', salary: salary, profession: '', workScope: state.workScope!);

        emit(state.copyWith(status: UiStatus.initial, clearErrorMessage: true));
        goNextStepInQueue();
      } catch (_) {
        emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось отправить данные о работе'));
      }
      return;
    }

    // обычный сценарий: profession + остальные поля
    final place = state.workPlace.trim();
    final adress = state.workAddress.trim();
    final profession = (state.professionValue ?? '').trim();

    if (place.isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите место работы'));
      return;
    }
    if (adress.isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Введите адрес организации'));
      return;
    }
    if (profession.isEmpty) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Выберите должность'));
      return;
    }

    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));
    try {
      await _repo.submitStep6Work(place: place, adress: adress, salary: salary, profession: profession, workScope: '');

      emit(state.copyWith(status: UiStatus.initial, clearErrorMessage: true));
      goNextStepInQueue();
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось отправить данные о работе'));
    }
  }

  void openProfessionDropdown() {
    emit(
      state.copyWith(
        isProfessionOpen: true,
        professionSuggestions: professionList,
        status: UiStatus.initial,
        clearErrorMessage: true,
        clearUploadPhotoError: true,
      ),
    );
  }

  void workScopeSelected(String value) {
    final next = (state.workScope == value) ? null : value;

    // если включили special-scope — очищаем всё кроме salary
    final bool enabledSpecial = next != null;

    emit(
      state.copyWith(
        workScope: next,
        setProfessionValueNull: true,
        isProfessionOpen: false,
        professionSuggestions: const [],
        workPlace: enabledSpecial ? '' : state.workPlace,
        workAddress: enabledSpecial ? '' : state.workAddress,
      ),
    );
  }

  void closeProfessionDropdown() {
    if (!state.isProfessionOpen && state.professionSuggestions.isEmpty) return;
    emit(state.copyWith(isProfessionOpen: false, professionSuggestions: const []));
  }

  void professionSelected(String v) {
    emit(
      state.copyWith(
        professionValue: v,
        setWorkScopeNull: true,
        isProfessionOpen: false,
        professionSuggestions: const [],
        status: UiStatus.initial,
        clearErrorMessage: true,
        workScope: null,
      ),
    );
  }

  void toggleWorkScope(String value) {
    final next = (state.workScope == value) ? null : value;

    emit(
      state.copyWith(
        workScope: next,
        setProfessionValueNull: true,
        isProfessionOpen: false,
        professionSuggestions: const [],
        status: UiStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  void workPlaceChanged(String v) {
    emit(state.copyWith(workPlace: v));

    // очистим адрес, если пользователь начал заново вводить
    // (опционально)
    // emit(state.copyWith(workAddress: ''));

    _workPlaceDebounce?.cancel();

    final q = v.trim();
    if (q.length < 3) {
      emit(state.copyWith(isWorkPlaceLoading: false, workPlaceSuggestions: const []));
      return;
    }

    _workPlaceDebounce = Timer(const Duration(milliseconds: 350), () async {
      emit(state.copyWith(isWorkPlaceLoading: true));

      try {
        final resp = await _dadata.fetchCompanies(query: q); // см. ниже
        emit(state.copyWith(isWorkPlaceLoading: false, workPlaceSuggestions: resp));
      } catch (e) {
        emit(state.copyWith(isWorkPlaceLoading: false, workPlaceSuggestions: const []));
      }
    });
  }

  void workPlaceSelected(CompanySuggestion s) {
    emit(
      state.copyWith(
        workPlace: s.name,
        workAddress: s.address, // ВАЖНО: подставляем адрес
        workPlaceSuggestions: const [],
        isWorkPlaceLoading: false,
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void regRegionChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(regRegion: v, status: UiStatus.initial, clearErrorMessage: true));
    _regRegionDebounce?.cancel();

    if (q.length < 3) {
      emit(state.copyWith(isRegRegionLoading: false, regRegionSuggestions: const []));
      return;
    }

    _regRegionDebounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isRegRegionLoading: true));
      try {
        final items = await _dadata.suggestRegions(query: q);
        if (isClosed) return;
        emit(state.copyWith(isRegRegionLoading: false, regRegionSuggestions: items));
      } catch (_) {
        if (isClosed) return;
        emit(state.copyWith(isRegRegionLoading: false, regRegionSuggestions: const []));
      }
    });
  }

  void regRegionSelected(RegionSuggestion s) {
    emit(
      state.copyWith(
        regRegion: s.title,
        regRegionFiasId: s.fiasId,
        regPostalCode: s.postalCode,

        // сбрасываем зависимые поля регистрации
        regLocality: '',
        regLocalityFiasId: null,
        regStreet: '',
        regHouse: '',
        regBuilding: '',
        regFlat: '',

        // закрываем подсказки
        isRegRegionLoading: false,
        regRegionSuggestions: const [],
        isRegLocalityLoading: false,
        regLocalitySuggestions: const [],
        isRegStreetLoading: false,
        regStreetSuggestions: const [],
      ),
    );
  }

  void regLocalityChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(regLocality: v, status: UiStatus.initial, clearErrorMessage: true));
    _regLocalityDebounce?.cancel();

    final regionFias = state.regRegionFiasId;
    if (regionFias == null || regionFias.isEmpty) {
      emit(state.copyWith(isRegLocalityLoading: false, regLocalitySuggestions: const []));
      return;
    }

    if (q.length < 3) {
      emit(state.copyWith(isRegLocalityLoading: false, regLocalitySuggestions: const []));
      return;
    }

    _regLocalityDebounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isRegLocalityLoading: true));
      try {
        final items = await _dadata.suggestCities(query: q, regionFiasId: regionFias);
        if (isClosed) return;
        emit(state.copyWith(isRegLocalityLoading: false, regLocalitySuggestions: items));
      } catch (_) {
        if (isClosed) return;
        emit(state.copyWith(isRegLocalityLoading: false, regLocalitySuggestions: const []));
      }
    });
  }

  void regLocalitySelected(CitySuggestion s) {
    emit(
      state.copyWith(
        regLocality: s.title,
        regLocalityFiasId: s.fiasId,
        regPostalCode: s.postalCode ?? state.regPostalCode,

        // сбрасываем улицу и ниже
        regStreet: '',
        regHouse: '',
        regBuilding: '',
        regFlat: '',

        isRegLocalityLoading: false,
        regLocalitySuggestions: const [],
        isRegStreetLoading: false,
        regStreetSuggestions: const [],
      ),
    );
  }

  void regStreetChanged(String v) {
    final q = v.trim();

    emit(state.copyWith(regStreet: v, status: UiStatus.initial, clearErrorMessage: true));
    _regStreetDebounce?.cancel();

    final regionFias = state.regRegionFiasId;
    final localityFias = state.regLocalityFiasId;

    if (regionFias == null || localityFias == null) {
      emit(state.copyWith(isRegStreetLoading: false, regStreetSuggestions: const []));
      return;
    }

    if (q.length < 3) {
      emit(state.copyWith(isRegStreetLoading: false, regStreetSuggestions: const []));
      return;
    }

    _regStreetDebounce = Timer(const Duration(milliseconds: 300), () async {
      emit(state.copyWith(isRegStreetLoading: true));
      try {
        final items = await _dadata.suggestStreets(query: q, regionFiasId: regionFias, localityFiasId: localityFias);
        if (isClosed) return;
        emit(state.copyWith(isRegStreetLoading: false, regStreetSuggestions: items));
      } catch (_) {
        if (isClosed) return;
        emit(state.copyWith(isRegStreetLoading: false, regStreetSuggestions: const []));
      }
    });
  }

  void regStreetSelected(StreetSuggestion s) {
    emit(state.copyWith(regStreet: s.title, isRegStreetLoading: false, regStreetSuggestions: const []));
  }

  Future<void> requestPaymentLink() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final link = await _cardRepo.getPaymentUrl();

      emit(state.copyWith(status: UiStatus.initial, paymentLink: link, openPaymentWebView: true));
    } catch (_) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось получить ссылку оплаты'));
    }
  }

  void consumeOpenPaymentWebView() {
    if (!state.openPaymentWebView) return;
    emit(state.copyWith(openPaymentWebView: false));
  }

  // внутри RegistrationFlowCubit

  Future<void> navAfterCardAdded(BuildContext context) async {
    // Чтобы не падать при повторных вызовах
    if (!context.mounted) return;

    emit(state.copyWith(status: UiStatus.loading, clearErrorMessage: true));

    try {
      final user = await _orderRepo.getUser();

      if (!context.mounted) return;

      if (user.hasBankSBP != 1) {
        emit(state.copyWith(status: UiStatus.initial));
        Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.registrationStepBankSelection, (r) => false);
        return;
      }

      emit(state.copyWith(status: UiStatus.initial));
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.homeScreen, (r) => false);
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: 'Не удалось проверить данные пользователя'));
    }
  }
}

