// features/orders/bloc/docs/doc_state.dart
import 'package:equatable/equatable.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/documents/data/models/doc_model.dart';

class DocState extends Equatable {
  final UiStatus status;
  final String? errorMessage;
  final List<DocModel> docs;

  const DocState({
    this.status = UiStatus.initial,
    this.errorMessage,
    this.docs = const [],
  });

  DocState copyWith({
    UiStatus? status,
    String? errorMessage,
    List<DocModel>? docs,
  }) {
    return DocState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      docs: docs ?? this.docs,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, docs];
}