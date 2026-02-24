enum UiStatus { initial, loading, success, failure }

abstract class UiState {
  UiStatus get status;
  String? get errorMessage;
}