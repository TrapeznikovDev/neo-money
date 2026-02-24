import 'package:neomoney/features/home/screens/main/data/models/partner_model.dart';

class OrderModel {
  final int? b2p;
  final dynamic payResult;
  final double? exceptAmount;
  final double? todayAmount;
  final double? discountAmount;
  final double? totalDebt;
  final double? sumPercent;
  final double? minAmount;
  final int? lastProlongation;
  final bool? consierge;
  final double? consiergeAmount;
  final String? consiergeNumber;
  final String? nextPayment;
  final bool? isAutoApprove;
  final bool? isFreePercent;
  final bool? isActiveZaem;
  final double? approvedAmount;
  final String? availableDate;
  final String? number;
  final String? activeDate;
  final String? zaimDate;
  final int? orderId;
  final String? promocode;
  final String? status;
  final int? statusCode;
  final bool? blackList;
  final dynamic maratory;
  final List<dynamic>? docs;
  final String? contract;
  final int? acceptContract;
  final String? recurent;
  final int? acceptRecurent;
  final double? premia;
  final double? sumInsure;
  final String? creditUrl;
  final String? acceptTitleOther;
  final String? acceptTitleRules;
  final String? acceptTitleConditions;
  final String? acceptTextOther;
  final String? acceptTextRules;
  final String? acceptTextConditions;
  final double? creditDoctorSumm;
  final String? fdChatLink;
  final String? modalText;
  final String? acceptTextKd;
  final String? acceptTextMulti;
  final String? multipolisDoc;
  final String? offerta;
  final String? soglashenia;
  final String? notificationLink;
  final bool? isOrganic;
  final double? vitaMedAmount;
  final double? fullPayVitaMedAmount;
  final bool? isNewClient;
  final String? ostatokOdDb;
  final double? ostatokOd1c;
  final double? calcPercents;
  final bool? additionalService;
  final bool? isVitaMedPaid;
  final bool? isMultipolisPaid;
  final List<PartnerModel>? partners;
  final bool? vitaMedEnabled;
  final bool? fullPayVitaMedEnabled;
  final double? minApprovedAmount;
  final bool? noActive;
  final double? oracleAmount;
  final bool? oracleEnabled;
  final int? fkConsiergePercent;
  final int? fkInsurancePercent;
  final int? fkOraclePercent;
  final String? arbitrationAgreement;
  final String discountTitle;
  final String discountDescription;

  final bool? isBonon;
  final bool? isBononTimeout;
  final String? bononTime;
  final String? receiptStatus;
  final String? receiptHintText;

  // final String discountDate;
  final String zaimDateTime;
  final bool? sbpEnabled;
  final bool? sbpReccurentsEnabled;
  final bool? autoConfirmEnabled;
  final int organizationId;
  final String loanType;
  final String cardType;
  final String cardId;
  final String confirmDate;
  final bool newProlongationFlow;

  OrderModel({
    required this.b2p,
    required this.payResult,
    required this.exceptAmount,
    required this.todayAmount,
    required this.discountAmount,
    required this.totalDebt,
    required this.sumPercent,
    required this.minAmount,
    required this.lastProlongation,
    required this.consierge,
    required this.consiergeAmount,
    required this.consiergeNumber,
    required this.nextPayment,
    required this.isAutoApprove,
    required this.isFreePercent,
    required this.isActiveZaem,
    required this.approvedAmount,
    required this.availableDate,
    required this.number,
    required this.activeDate,
    required this.zaimDate,
    required this.orderId,
    required this.promocode,
    required this.status,
    required this.statusCode,
    required this.blackList,
    required this.maratory,
    required this.docs,
    required this.contract,
    required this.acceptContract,
    required this.recurent,
    required this.acceptRecurent,
    required this.premia,
    required this.sumInsure,
    required this.creditUrl,
    required this.acceptTitleOther,
    required this.acceptTitleRules,
    required this.acceptTitleConditions,
    required this.acceptTextOther,
    required this.acceptTextRules,
    required this.acceptTextConditions,
    required this.creditDoctorSumm,
    required this.fdChatLink,
    required this.modalText,
    required this.acceptTextKd,
    required this.acceptTextMulti,
    required this.multipolisDoc,
    required this.offerta,
    required this.soglashenia,
    required this.notificationLink,
    required this.isOrganic,
    required this.vitaMedAmount,
    required this.fullPayVitaMedAmount,
    required this.isNewClient,
    required this.ostatokOdDb,
    required this.ostatokOd1c,
    required this.calcPercents,
    required this.additionalService,
    required this.isVitaMedPaid,
    required this.isMultipolisPaid,
    required this.partners,
    required this.vitaMedEnabled,
    required this.fullPayVitaMedEnabled,
    required this.minApprovedAmount,
    required this.noActive,
    required this.oracleAmount,
    required this.oracleEnabled,
    required this.fkConsiergePercent,
    required this.fkInsurancePercent,
    required this.fkOraclePercent,
    required this.arbitrationAgreement,
    required this.discountTitle,
    required this.discountDescription,
    // required this.discountDate,
    required this.zaimDateTime,
    required this.sbpEnabled,
    required this.sbpReccurentsEnabled,
    required this.autoConfirmEnabled,
    required this.organizationId,
    required this.isBonon,
    required this.bononTime,
    required this.isBononTimeout,
    required this.loanType,
    required this.cardType,
    required this.cardId,
    required this.confirmDate,
    required this.receiptStatus,
    required this.receiptHintText,
    required this.newProlongationFlow,
  });

  factory OrderModel.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic> partnersJson,
      ) {
    return OrderModel(
      b2p: json['b2p'] is int
          ? json['b2p']
          : int.tryParse(json['b2p'].toString()),
      payResult: json['pay_result'],
      exceptAmount: (json['except_amount'] as num?)?.toDouble() ?? 0,
      todayAmount: (json['today_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
      sumPercent: (json['sum_percent'] as num?)?.toDouble() ?? 0,
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0,
      lastProlongation: json['last_prolongation'] is int
          ? json['last_prolongation']
          : int.tryParse(json['last_prolongation'].toString()),
      consierge: json['consierge'],
      consiergeAmount: (json['consierge_amount'] as num?)?.toDouble() ?? 0,
      consiergeNumber: json['consierge_number']?.toString(),
      nextPayment: json['next_payment']?.toString(),
      isAutoApprove: json['is_auto_approve'],
      isFreePercent: json['is_free_percent'],
      isActiveZaem: json['is_active_zaem'],
      approvedAmount: (json['approved_amount'] as num?)?.toDouble() ?? 0,
      availableDate: json['available_date']?.toString() ?? '',
      number: json['number']?.toString(),
      activeDate: json['active_date']?.toString(),
      zaimDate: json['zaim_date']?.toString(),
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id'].toString()),
      promocode: json['promocode']?.toString(),
      status: json['status']?.toString(),
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code'].toString()),
      blackList: json['black_list'],
      maratory: json['maratory'],
      docs: json['docs'],
      contract: json['contract']?.toString(),
      acceptContract: json['accept_contract'] is int
          ? json['accept_contract']
          : int.tryParse(json['accept_contract'].toString()),
      recurent: json['recurent']?.toString(),
      acceptRecurent: json['accept_recurent'] is int
          ? json['accept_recurent']
          : int.tryParse(json['accept_recurent'].toString()),
      premia: (json['premia'] as num?)?.toDouble(),
      sumInsure: (json['sum_insure'] as num?)?.toDouble(),
      creditUrl: json['credit_url']?.toString(),
      acceptTitleOther: json['accept_title_other']?.toString(),
      acceptTitleRules: json['accept_title_rules']?.toString(),
      acceptTitleConditions: json['accept_title_conditions']?.toString(),
      acceptTextOther: json['accept_text_other']?.toString(),
      acceptTextRules: json['accept_text_rules']?.toString(),
      acceptTextConditions: json['accept_text_conditions']?.toString(),
      creditDoctorSumm: (json['credit_doctor_summ'] as num?)?.toDouble() ?? 0,
      modalText: json['modal_text']?.toString(),
      acceptTextKd: json['accept_text_kd']?.toString(),
      acceptTextMulti: json['accept_text_multi']?.toString(),
      multipolisDoc: json['multipolis_doc']?.toString(),
      offerta: json['offerta']?.toString(),
      soglashenia: json['soglashenia']?.toString(),
      notificationLink: json['notification_link']?.toString(),
      isOrganic: json['is_organic'],
      vitaMedAmount: (json['vita_med_amount'] as num?)?.toDouble() ?? 0,
      fullPayVitaMedAmount:
      (json['full_pay_vita_med_amount'] as num?)?.toDouble() ?? 0,
      isNewClient: json['is_new_client'],
      ostatokOdDb: json['ostatok_od_db']?.toString(),
      ostatokOd1c: (json['ostatok_od_1c'] as num?)?.toDouble() ?? 0,
      calcPercents: (json['calc_percents'] as num?)?.toDouble() ?? 0,
      additionalService: json['additional_service'],
      isVitaMedPaid: json['is_vita_med_paid'],
      isMultipolisPaid: json['is_multipolis_paid'],
      partners: parsePartners(partnersJson['partners']),
      vitaMedEnabled: json['vitamed_enabled'],
      fullPayVitaMedEnabled: json['full_pay_vitamed_enabled'],
      minApprovedAmount: (json['min_approved_amount'] as num?)?.toDouble() ?? 0,
      noActive: json['noactive'],
      oracleAmount: (json['oracle_amount'] as num?)?.toDouble() ?? 0,
      oracleEnabled: json['oracle_enabled'],
      fdChatLink: json['fd_chat_link']?.toString(),
      fkConsiergePercent: json['fk_consierge_percent'] is int
          ? json['fk_consierge_percent']
          : int.tryParse(json['fk_consierge_percent'].toString()),
      fkInsurancePercent: json['fk_insurance_percent'] is int
          ? json['fk_insurance_percent']
          : int.tryParse(json['fk_insurance_percent'].toString()),
      fkOraclePercent: json['fk_oracle_percent'] is int
          ? json['fk_oracle_percent']
          : int.tryParse(json['fk_oracle_percent'].toString()),
      arbitrationAgreement: json['arbitration_agreement']?.toString(),
      discountTitle: json['discount_title']?.toString() ?? '',
      discountDescription: json['discount_description']?.toString() ?? '',
      zaimDateTime: json['zaim_datetime']?.toString() ?? '',
      sbpEnabled: partnersJson['settings']['sbp_enabled'] ?? false,
      sbpReccurentsEnabled:
      partnersJson['settings']['sbp_recurrents_enabled'] ?? false,
      autoConfirmEnabled:
      partnersJson['settings']['autoconfirm_enabled'] ?? false,
      organizationId: json['organization_id'] is int
          ? json['organization_id']
          : int.tryParse(json['organization_id'].toString()) ?? 0,
      isBonon: json['is_bonon'] ?? false,
      isBononTimeout: json['is_bonon_timeout'] ?? false,
      bononTime: json['bonon_time']?.toString(),
      loanType: json['loan_type']?.toString() ?? '',
      cardType: json['card_type']?.toString() ?? '',
      cardId: json['card_id']?.toString() ?? '',
      confirmDate: json['confirm_date']?.toString() ?? '',
      receiptHintText: json['receipt_hint_text']?.toString() ?? '',
      receiptStatus: json['receipt_status']?.toString() ?? '',
      newProlongationFlow: json['new_prolongation_flow'] ?? false,
    );
  }

  bool get hasDiscount => (((discountAmount ?? 0.0) > 0) &&
      ((discountAmount ?? 0.0) < (todayAmount ?? 0.0)));
  String get statusMetrica => 'status: $status - $statusCode';
}

List<PartnerModel> parsePartners(dynamic partnersJson) {
  if (partnersJson == null) {
    return [];
  }

  if (partnersJson is List) {
    return partnersJson
        .map((partner) =>
        PartnerModel.fromJson(partner as Map<String, dynamic>))
        .toList();
  }

  throw Exception('Unexpected type for partners: ${partnersJson.runtimeType}');
}
