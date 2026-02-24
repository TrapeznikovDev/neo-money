import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import '../repository/documents_repository.dart';
import 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  final DocumentsRepository _repo;

  DocumentsCubit(this._repo) : super(const DocumentsState.initial());

  Future<void> init() async {
    if (state.status == UiStatus.initial) {
      await load();
    }
  }

  Future<void> load() async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));
    try {
      final model = await _repo.fetchCompanyDocs();

      log('company_docs loaded: ${model.docs.length} docs', name: 'DocumentsCubit');

      emit(state.copyWith(
        status: UiStatus.success,
        docs: model.docs,
      ));
    } catch (e, st) {
      log('company_docs failed: $e', name: 'DocumentsCubit', stackTrace: st);
      emit(state.copyWith(
        status: UiStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }


}