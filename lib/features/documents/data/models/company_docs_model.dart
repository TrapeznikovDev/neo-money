import 'package:equatable/equatable.dart';
import 'comp_docs_model.dart';

class CompanyDocsModel extends Equatable {
  final bool dopDocsEnabled;
  final bool otherDocsEnabled;
  final List<CompDocsModel> docs;

  const CompanyDocsModel({
    required this.dopDocsEnabled,
    required this.otherDocsEnabled,
    required this.docs,
  });

  factory CompanyDocsModel.fromJson(Map<String, dynamic> json) {
    final docsJson = (json['docs'] as List?) ?? const [];

    return CompanyDocsModel(
      dopDocsEnabled: (json['dop_docs_enabled'] as bool?) ?? false,
      otherDocsEnabled: (json['other_docs_enabled'] as bool?) ?? false,
      docs: docsJson
          .whereType<Map<String, dynamic>>()
          .map(CompDocsModel.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [dopDocsEnabled, otherDocsEnabled, docs];
}