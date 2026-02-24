import 'package:equatable/equatable.dart';

class CompDocsModel extends Equatable {
  final int id;
  final String name;
  final String url;

  const CompDocsModel({
    required this.id,
    required this.name,
    required this.url,
  });

  factory CompDocsModel.fromJson(Map<String, dynamic> json) {
    return CompDocsModel(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      url: (json['url'] as String?) ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, url];
}