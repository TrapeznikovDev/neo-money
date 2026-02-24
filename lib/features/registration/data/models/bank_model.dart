// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class BankModel extends Equatable {
  final int id;
  final String title;
  const BankModel({
    required this.id,
    required this.title,
  });

  factory BankModel.empty() {
    return const BankModel(
      id: 0,
      title: '',
    );
  }

  BankModel copyWith({
    int? id,
    String? title,
  }) {
    return BankModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
    };
  }

  factory BankModel.fromMap(Map<String, dynamic> map) {
    return BankModel(
      id: map['id'] as int,
      title: map['title'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BankModel.fromJson(String source) =>
      BankModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BankModel(id: $id, title: $title)';

  @override
  List<Object?> get props => [id, title];
}
