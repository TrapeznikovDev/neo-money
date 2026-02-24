class NkLightFlowModel {
  final bool skipPhoto;
  final bool skipWork;

  NkLightFlowModel({required this.skipPhoto, required this.skipWork});

  factory NkLightFlowModel.disabled() {
    return NkLightFlowModel(skipPhoto: false, skipWork: false);
  }
}