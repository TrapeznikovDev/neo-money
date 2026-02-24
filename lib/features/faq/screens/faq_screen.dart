import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/core/presentation/base_bloc_page.dart';
import 'package:neomoney/core/presentation/state/ui_state.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';
import 'package:neomoney/features/faq/cubit/faq_cubit.dart';
import 'package:neomoney/features/faq/cubit/faq_state.dart';
import 'package:neomoney/features/faq/models/question_answer_model.dart';

class FaqScreen extends BaseBlocPage<FaqCubit, FaqState> {
  const FaqScreen({super.key});

  @override
  FaqCubit createBloc(BuildContext context) => getIt<FaqCubit>();

  @override
  bool get automaticallyImplyLeading => false;

  @override
  String? get title => null;

  @override
  Widget buildBody(BuildContext context, FaqState state) {
    final cubit = context.read<FaqCubit>();
    final sections = state.sections;
    final hasQuery = cubit.controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: state.status == UiStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator.adaptive(
        onRefresh: cubit.load,
        child: Column(
          children: [
            _QuestionsSearchBar(
              controller: cubit.controller,
              onChanged: (_) => cubit.onChanged(),
              onClear: cubit.onClear,
            ),
            const SizedBox(height: 12),

            if (hasQuery)
              Expanded(
                child: _QuestionsList(
                  items: state.filteredQuestions,
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: sections.keys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final section = sections.keys.elementAt(index);
                    final qa = sections[section] ?? const <QuestionAnswerModel>[];

                    return InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FaqSectionScreen(
                            section: section,
                            items: qa,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                section,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(CupertinoIcons.right_chevron, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (state.status == UiStatus.failure && (state.errorMessage?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errorMessage!,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuestionsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _QuestionsSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Поиск',
      controller: controller,
      onChanged: onChanged,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(10)),
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      hintStyle: WidgetStatePropertyAll(
        AppTypography.textTheme.bodyLarge?.copyWith(color: Colors.black38),
      ),
      trailing: [
        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            controller.clear();
            FocusManager.instance.primaryFocus?.unfocus();
            onClear();
          },
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(CupertinoIcons.xmark, color: Colors.black),
          ),
        )
      ],
    );
  }
}

class FaqSectionScreen extends StatelessWidget {
  final String section;
  final List<QuestionAnswerModel> items;

  const FaqSectionScreen({
    super.key,
    required this.section,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor,
      appBar: AppBar(
        title: Text(section),
        backgroundColor: AppColors.backColor,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _QaTile(item: items[i]),
      ),
    );
  }
}

class _QuestionsList extends StatelessWidget {
  final List<QuestionAnswerModel> items;
  const _QuestionsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'Ничего не найдено',
          style: AppTypography.textTheme.bodyLarge?.copyWith(color: Colors.black54),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _QaTile(item: items[i]),
    );
  }
}

class _QaTile extends StatelessWidget {
  final QuestionAnswerModel item;
  const _QaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
        collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
        title: Text(
          item.question,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            item.answer,
            style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.black87, height: 1.3),
          ),
        ],
      ),
    );
  }
}