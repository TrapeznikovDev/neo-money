import 'package:flutter/material.dart';
import 'package:neomoney/core/validation/phone_input_formater.dart';

class StepPhoneBase extends StatelessWidget {
  final bool isSmsRequested;
  final int resendSecondsLeft;

  final TextEditingController phoneController;
  final TextEditingController smsController;

  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onSmsChanged;
  final VoidCallback onResend;

  const StepPhoneBase({
    super.key,
    required this.isSmsRequested,
    required this.resendSecondsLeft,
    required this.phoneController,
    required this.smsController,
    required this.onPhoneChanged,
    required this.onSmsChanged,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isSmsRequested) ...[
          SizedBox(
            height: 62,
            child: TextField(
              controller: phoneController,
              inputFormatters: [PhoneInputFormatter()],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Номер телефона*'),
              onChanged: onPhoneChanged,
            ),
          ),
        ] else ...[
          const SizedBox(height: 24),
          const Text(
            'Введите номер телефона',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 62,
            child: TextField(
              controller: phoneController,
              inputFormatters: [PhoneInputFormatter()],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+7 000 00 00 00'),
              onChanged: onPhoneChanged,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 62,
            child: TextField(
              controller: smsController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              buildCounter: (_, {required currentLength, required maxLength, required isFocused}) => null,
              decoration: const InputDecoration(hintText: 'Код из СМС'),
              onChanged: onSmsChanged,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              resendSecondsLeft > 0
                  ? '00:${resendSecondsLeft.toString().padLeft(2, '0')} до возможности\nповторной отправки кода'
                  : 'Можно отправить код повторно',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black38),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: resendSecondsLeft > 0 ? null : onResend,
              child: const Text('Отправить код повторно'),
            ),
          ),
        ],
      ],
    );
  }
}