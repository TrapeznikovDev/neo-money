import 'package:equatable/equatable.dart';
import 'package:neomoney/cloacka/features/app_start/data/dto/app_info_dto.dart';

sealed class AppStartState extends Equatable {
  const AppStartState();

  @override
  List<Object?> get props => [];
}

class AppStartInitial extends AppStartState {
  const AppStartInitial();
}

class AppStartLoading extends AppStartState {
  const AppStartLoading();
}

class AppStartLoaded extends AppStartState {
  final AppInfoDto info;
  final String nextRoute;

  const AppStartLoaded(this.info, this.nextRoute);

  @override
  List<Object?> get props => [info, nextRoute];
}

class AppStartError extends AppStartState {
  final String message;

  const AppStartError(this.message);

  @override
  List<Object?> get props => [message];
}