import 'package:equatable/equatable.dart';
import 'company_docs_model.dart';

class CompanyDocsResponse extends Equatable {
  final bool success;
  final int status;
  final CompanyDocsModel data;

  const CompanyDocsResponse({
    required this.success,
    required this.status,
    required this.data,
  });

  factory CompanyDocsResponse.fromJson(Map<String, dynamic> json) {
    return CompanyDocsResponse(
      success: (json['success'] as bool?) ?? false,
      status: (json['status'] as num?)?.toInt() ?? 0,
      data: CompanyDocsModel.fromJson((json['data'] as Map?)?.cast<String, dynamic>() ?? const {}),
    );
  }

  @override
  List<Object?> get props => [success, status, data];
}