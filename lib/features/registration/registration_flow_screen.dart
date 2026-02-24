import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/app/router.dart';
import 'package:neomoney/cloacka/core/storage/app_info_storage.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/core/ui/widgets/top_progress.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';
import 'package:neomoney/features/registration/steps/payment_web_view.dart';
import 'package:neomoney/features/registration/steps/step_address.dart';
import 'package:neomoney/features/registration/steps/step_card.dart';
import 'package:neomoney/features/registration/steps/step_name.dart';
import 'package:neomoney/features/registration/steps/step_passport.dart';
import 'package:neomoney/features/registration/steps/step_passport_photos.dart';
import 'package:neomoney/features/registration/steps/step_preaprove.dart';
import 'package:neomoney/features/registration/steps/step_work.dart';

class RegistrationFlowScreen extends BaseBlocPage<RegistrationFlowCubit, RegistrationFlowState> {
  const RegistrationFlowScreen({super.key});

  @override
  RegistrationFlowCubit createBloc(BuildContext context) => getIt<RegistrationFlowCubit>();

  @override
  bool get automaticallyImplyLeading => true;

  @override
  String? get title => null;

  @override
  Widget buildBody(BuildContext context, RegistrationFlowState state) {
    return BlocListener<RegistrationFlowCubit, RegistrationFlowState>(
      listenWhen: (p, n) => !p.openPaymentWebView && n.openPaymentWebView,
      listener: (context, s) async {
        if ((s.paymentLink ?? '').isEmpty) return;

        final cubit = context.read<RegistrationFlowCubit>();

        cubit.consumeOpenPaymentWebView();

        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(
              url: s.paymentLink!,
            ),
          ),
        );

        if (!context.mounted) return;

        if (result == true) {
          await cubit.navAfterCardAdded(context);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          final cubit = context.read<RegistrationFlowCubit>();
          final currentStep = cubit.state.step;

          if (currentStep != RegStep.fio) {
            cubit.prev();
            return;
          }

          final confirm = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Закрыть регистрацию?'),
              content: const Text('Действительно хотите закрыть? Данные не будут сохранены.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  isDefaultAction: true,
                  child: const Text('Нет'),
                ),
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  isDestructiveAction: true,
                  child: const Text('Да'),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          cubit.abortRegistrationAndClearToken();

          if (!context.mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(AppRouteNames.authScreen, (r) => false);
        },
        child: _RegistrationFlowBody(state: state),
      ),
    );
  }
}

class _RegistrationFlowBody extends StatefulWidget {
  final RegistrationFlowState state;

  const _RegistrationFlowBody({required this.state});

  @override
  State<_RegistrationFlowBody> createState() => _RegistrationFlowBodyState();
}

class _RegistrationFlowBodyState extends State<_RegistrationFlowBody> {
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();

  static const Map<RegStep, int> _approvalByStep = {
    RegStep.fio: 52,
    RegStep.passport: 69,
    RegStep.address: 85,
    RegStep.preapproved: 85,
    RegStep.photo: 85,
    RegStep.work: 91,
    RegStep.card: 91,
  };

  static const List<String> _firstTitleList = [
    'Заполните данные',
    'Паспортные данные',
    'Паспортные данные',
    'Предварительное одобрение',
    'Фото паспорта и карты',
    'Место работы',
    'Банковская карта',
  ];

  static const List<String> _secondTitleList = [
    'Для авторизации необходимо ввести Ваш номер телефона.',
    'Мы пришлем Вам код для продолжения заявки',
    'Решение за 1 минуту по паспорту',
    'Решение за 1 минуту по паспорту',
    'Выберите желаемую сумму',
    'Заполните паспортные данные',
    'Заполните данные о работе',
    'Прикрепите банковскую карту',
  ];

  String _probabilityText(RegStep step) {
    final p = _approvalByStep[step] ?? 32;
    return '+$p% к вероятности одобрения займа';
  }

  String _firstTitle(RegStep step) {
    return _firstTitleList[step.index];
  }

  String _secondTitle(RegStep step) {
    return _secondTitleList[step.index];
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();
    final s = widget.state;
    final appInfo = getIt<AppInfoStorage>();

    return Column(
      children: [
        TopProgress(
          step: s.stepIndex + 1,
          total: s.totalSteps,
          probabilityText: _probabilityText(s.step),
          firstTitle: _firstTitle(s.step),
          secondTitle: _secondTitle(s.step),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            //TODO удалить перед релизом
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v > 250) {
                cubit.prev();
              } else if (v < -250) {
                cubit.debugNextStep();
              }
            },

            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
                              );
                            },
                            child: KeyedSubtree(key: ValueKey<RegStep>(s.step), child: _buildStep(s)),
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(
                                  height: 58,
                                  child: ElevatedButton(onPressed: s.status == UiStatus.loading ? null : cubit.onNextPressed, child: Text(_buttonText(s))),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  appInfo.registrationOrganizationInfo ?? '',
                                  style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.textGrey, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep(RegistrationFlowState s) {
    switch (s.step) {

      case RegStep.fio:
        return const StepFullName();

      case RegStep.passport:
        return const StepPassport();

      case RegStep.address:
        return const StepPassportAddress();

      case RegStep.preapproved:
        return const StepPreApprove();

      case RegStep.photo:
        return const StepPassportPhotos();

      case RegStep.work:
        return const StepWork();

      case RegStep.card:
        return const StepCard();
    }
  }

  String _buttonText(RegistrationFlowState s) {
    if (s.step == RegStep.card) {
      return 'Привязать карту';
    }
    if (s.step == RegStep.work) {
      return 'Получить деньги';
    }
    return 'Далее';
  }
}
