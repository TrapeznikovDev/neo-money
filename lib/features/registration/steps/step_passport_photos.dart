import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/registration/cubit/registration_cubit.dart';
import 'package:neomoney/features/registration/cubit/registration_state.dart';

class StepPassportPhotos extends StatelessWidget {
  const StepPassportPhotos({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegistrationFlowCubit>();

    return BlocBuilder<RegistrationFlowCubit, RegistrationFlowState>(
      buildWhen: (p, n) =>
          p.passportPhoto1 != n.passportPhoto1 ||
          p.isUploadingPassportPhoto1 != n.isUploadingPassportPhoto1 ||
          p.uploadPhotoError != n.uploadPhotoError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Прикрепите фото 3 и 4 страницы паспорта\n(разворот с фотографией)',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 26),

            _PhotoArea(
              file: state.passportPhoto1,
              isLoading: state.isUploadingPassportPhoto1,
              onTap: () => _showPickSheet(context, onCamera: cubit.pickPassportPhoto1FromCamera, onGallery: cubit.pickPassportPhoto1FromGallery),
            ),

            if ((state.uploadPhotoError ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                state.uploadPhotoError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const SizedBox(height: 22),
          ],
        );
      },
    );
  }

  static Future<void> _showPickSheet(BuildContext context, {required VoidCallback onCamera, required VoidCallback onGallery}) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Сфотографировать'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Выбрать из галереи'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhotoArea extends StatelessWidget {
  final File? file;
  final bool isLoading;
  final VoidCallback onTap;

  const _PhotoArea({required this.file, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 302,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (file != null)
              Image.file(file!, fit: BoxFit.cover)
            else
              Center(child: Image.asset('assets/icons/passport_icon.png')),

            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
