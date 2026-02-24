class DadataFmsUnit {
  final String code;
  final String name;

  DadataFmsUnit({
    required this.code,
    required this.name,
  });

  factory DadataFmsUnit.fromJson(Map<String, dynamic> json) {
    return DadataFmsUnit(
      code: json['data']?['code'] ?? '',
      name: json['value'] ?? '',
    );
  }
}