class ImagesInfoModel {
  final String type;
  final int status;

  ImagesInfoModel({
    required this.status,
    required this.type,
  });

  factory ImagesInfoModel.fromJson(Map<String, dynamic> json) {
    return ImagesInfoModel(
      type: json['type'] as String,
      status: json['status'] as int? ?? 0,
    );
  }
}
