class DadataCompany {
  final String name;
  final String inn;

  DadataCompany({
    required this.name,
    required this.inn,
  });

  factory DadataCompany.fromJson(Map<String, dynamic> json) {
    return DadataCompany(
      name: json['value'],
      inn: json['data']?['inn'] ?? '',
    );
  }
}