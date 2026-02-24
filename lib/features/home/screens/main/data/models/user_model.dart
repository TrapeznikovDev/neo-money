import 'dart:io';

class UserModel {
  final int? id;
  final String? lastname;
  final String? firstname;
  final String? patronymic;
  final String? birth;
  final String? email;
  final String? passportSerial;
  final String? passportDate;
  final String? subdivisionCode;
  final String? passportIssued;
  final String? gender;
  final String? birthPlace;
  final String? maritalStatus;
  final String? Regregion;
  final String? Regcity;
  final String? Regstreet;
  final String? Reghousing;
  final String? Regindex;
  final String? Regroom;
  final String? Faktregion;
  final String? Faktcity;
  final String? Faktstreet;
  final String? Fakthousing;
  final String? Faktindex;
  final String? Faktroom;
  final String? workplace;
  final String? workAddress;
  final File? passport;
  final File? card;
  final String? workScope;
  final String? incomeBase;
  final String? profession;
  final bool? sbpAdded;
  final String? phoneMobile;
  final int? firstLoan;
  final int? hasBankSBP;
  final int? showBanner;
  final String? bannerLink;

  UserModel({
    this.id,
    this.lastname,
    this.firstname,
    this.patronymic,
    this.birth,
    this.email,
    this.passportSerial,
    this.passportDate,
    this.subdivisionCode,
    this.passportIssued,
    this.gender,
    this.birthPlace,
    this.maritalStatus,
    this.Regregion,
    this.Regcity,
    this.Regstreet,
    this.Reghousing,
    this.Regindex,
    this.Regroom,
    this.Faktregion,
    this.Faktcity,
    this.Faktstreet,
    this.Fakthousing,
    this.Faktindex,
    this.Faktroom,
    this.workplace,
    this.workAddress,
    this.card,
    this.passport,
    this.workScope,
    this.incomeBase,
    this.profession,
    this.sbpAdded,
    this.phoneMobile,
    this.firstLoan,
    this.hasBankSBP,
    this.showBanner,
    this.bannerLink,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      lastname: json['lastname'] as String?,
      firstname: json['firstname'] as String?,
      patronymic: json['patronymic'] as String?,
      birth: json['birth'] as String?,
      email: json['email'] as String?,
      passportSerial: json['passport_serial'] as String?,
      passportDate: json['passport_date'] as String?,
      subdivisionCode: json['subdivision_code'] as String?,
      passportIssued: json['passport_issued'] as String?,
      gender: json['gender'] as String?,
      birthPlace: json['birth_place'] as String?,
      maritalStatus: json['marital_status'] as String?,
      Regregion: json['Regregion'] as String?,
      Regcity: json['Regcity'] as String?,
      Regstreet: json['Regstreet'] as String?,
      Reghousing: json['Reghousing'] as String?,
      Regindex: json['Regindex'] as String?,
      Regroom: json['Regroom'] as String?,
      Faktregion: json['Faktregion'] as String?,
      Faktcity: json['Faktcity'] as String?,
      Faktstreet: json['Faktstreet'] as String?,
      Fakthousing: json['Fakthousing'] as String?,
      Faktindex: json['Faktindex'] as String?,
      Faktroom: json['Faktroom'] as String?,
      workplace: json['workplace'] as String?,
      workAddress: json['work_address'] as String?,
      incomeBase: json['income_base'] as String?,
      workScope: json['work_scope'] as String?,
      profession: json['profession'] as String?,
      sbpAdded: json['sbp_added'] as bool?,
      phoneMobile: json['phone_mobile'] as String?,
      firstLoan: json['first_loan'] as int?,
      hasBankSBP: json['has_sbp_bank'] as int?,
      showBanner: json['show_banner'] as int?,
      bannerLink: json['banner_link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lastname': lastname,
      'firstname': firstname,
      'patronymic': patronymic,
      'birth': birth,
      'email': email,
      'passport_serial': passportSerial,
      'passport_date': passportDate,
      'subdivision_code': subdivisionCode,
      'passport_issued': passportIssued,
      'gender': gender,
      'birth_place': birthPlace,
      'marital_status': maritalStatus,
      'Regregion': Regregion,
      'Regcity': Regcity,
      'Regstreet': Regstreet,
      'Reghousing': Reghousing,
      'Regindex': Regindex,
      'Regroom': Regroom,
      'Faktregion': Faktregion,
      'Faktcity': Faktcity,
      'Faktstreet': Faktstreet,
      'Fakthousing': Fakthousing,
      'Faktindex': Faktindex,
      'Faktroom': Faktroom,
      'workplace': workplace,
      'work_address': workAddress,
      'work_scope': workScope,
      'work_staff': incomeBase,
      'profession': profession,
      'sbp_added': sbpAdded,
      'phone_mobile': phoneMobile,
      'first_loan': firstLoan,
      'has_sbp_bank': hasBankSBP,
      'show_banner': showBanner,
      'banner_link': bannerLink,
    };
  }
}
