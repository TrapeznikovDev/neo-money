class DocModel {
  final int id;
  final String text;
  final String? link;
  final String? textLink;
  final String? createdAt;
  final String? updatedAt;
  final int isAdditional;

  DocModel({
    required this.id,
    required this.text,
    this.link,
    required this.textLink,
    this.createdAt,
    this.updatedAt,
    required this.isAdditional,
  });

  factory DocModel.fromJson(Map<String, dynamic> json) {
    return DocModel(
      id: json['id'] as int,
      text: json['text'] as String,
      link: json['link'] as String?,
      textLink: json['text_link'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      isAdditional: json['is_additional'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'link': link,
      'text_link': textLink,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_additional': isAdditional,
    };
  }
}
