import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';

class StepCard extends StatelessWidget {
  const StepCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();

    return BlocBuilder<RegistrationFlowCubit, RegistrationFlowState>(
      builder: (context, s) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            cubit.closeProfessionDropdown();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/icons/card_add_icon.png'),
            ],
          ),
        );
      },
    );
  }
}
