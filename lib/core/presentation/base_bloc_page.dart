import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/widgets/default_app_bar.dart';

typedef BlocCreator<B> = B Function(BuildContext context);

abstract class BaseBlocPage<B extends BlocBase<S>, S extends UiState> extends StatelessWidget {
  const BaseBlocPage({super.key});

  B createBloc(BuildContext context);

  Widget buildBody(BuildContext context, S state);

  bool get useAppBar => true;

  bool get useScaffold => true;

  String? get title => null;

  bool get automaticallyImplyLeading => true;

  Widget? buildTrailing(BuildContext context) => null;

  void onStateChanged(BuildContext context, S state) {}

  Color? get backgroundColor => null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: createBloc,
      child: BlocConsumer<B, S>(
        listenWhen: (prev, next) {
          return prev.status != next.status || prev.errorMessage != next.errorMessage;
        },
        listener: (ctx, state) {
          if (state.status == UiStatus.failure &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(ctx)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          onStateChanged(ctx, state);
        },
        builder: (ctx, state) {
          final content = _buildContent(ctx, state);

          if (!useScaffold) {
            return content;
          }

          return Scaffold(
            backgroundColor: backgroundColor ?? AppColors.scaffold,
            appBar: useAppBar
                ? DefaultAppBar(title: title, trailing: buildTrailing(ctx), automaticallyImplyLeading: automaticallyImplyLeading)
                : null,
            body: SafeArea(child: content),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, S state) {
    final pageContent = buildBody(context, state);
    return Padding(padding: const EdgeInsets.only(left: 25, right: 25, bottom: 22), child: pageContent);
  }
}
