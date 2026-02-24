class PartnerModel {
  final String? id;
  final String href;
  final String name;
  final String? dateAdded;

  PartnerModel({
    required this.id,
    required this.href,
    required this.name,
    required this.dateAdded,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'],
      href: json['href'],
      name: json['name'],
      dateAdded: json['date_added'],
    );
  }
}
