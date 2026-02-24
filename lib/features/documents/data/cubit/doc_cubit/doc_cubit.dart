// features/orders/bloc/docs/doc_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/features/home/screens/main/data/repository/orders_repository.dart';
import 'doc_state.dart';

class DocCubit extends Cubit<DocState> {
  final OrderRepository _repo;

  DocCubit(this._repo) : super(const DocState());

  Future<void> loadDocs(String type) async {
    emit(state.copyWith(status: UiStatus.loading, errorMessage: null));

    try {
      final docs = await _repo.getDocs(type: type);
      emit(state.copyWith(status: UiStatus.success, docs: docs));
    } catch (e) {
      emit(state.copyWith(status: UiStatus.failure, errorMessage: e.toString()));
    }
  }
}