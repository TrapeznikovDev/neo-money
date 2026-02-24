import 'package:equatable/equatable.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import '../models/comp_docs_model.dart';

class DocumentsState extends Equatable implements UiState {
  @override
  final UiStatus status;

  @override
  final String? errorMessage;

  final List<CompDocsModel> docs;

  const DocumentsState({
    required this.status,
    required this.errorMessage,
    required this.docs,
  });

  const DocumentsState.initial()
      : status = UiStatus.initial,
        errorMessage = null,
        docs = const [];

  DocumentsState copyWith({
    UiStatus? status,
    String? errorMessage,
    List<CompDocsModel>? docs,
  }) {
    return DocumentsState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      docs: docs ?? this.docs,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, docs];
}