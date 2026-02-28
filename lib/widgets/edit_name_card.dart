import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_form_textfield.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/massage_dialog.dart';

class EditNameCard extends StatefulWidget {
  const EditNameCard({super.key});

  @override
  State<EditNameCard> createState() => _EditNameCardState();
}

class _EditNameCardState extends State<EditNameCard> {
  bool expanded = false;

  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              defaultText(
                context: context,
                text: isArabic ? "تعديل الاسم" : "Edit Name",
                size: 16,
                isCenter: false,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
              ),
            ],
          ),

          if (expanded) ...[
            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomFormTextField(
                    labelText: isArabic ? "الاسم الأول" : "First Name",
                    hintText: isArabic
                        ? "ادخل الاسم الأول"
                        : "Enter first name",
                    controller: firstNameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.name,
                  ),
                  const SizedBox(height: 12),

                  CustomFormTextField(
                    labelText: isArabic ? "اسم العائلة" : "Family Name",
                    hintText: isArabic
                        ? "ادخل اسم العائلة"
                        : "Enter family name",
                    controller: lastNameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: CustomTextFieldType.name,
                  ),

                  const SizedBox(height: 16),

                  CustomGlowButton(
                    title: isArabic ? "حفظ" : "Save",
                    width: double.infinity,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final first = firstNameController.text.trim();
                      final last = lastNameController.text.trim();

                      await context.read<UserCubit>().updateName(
                        firstName: first,
                        lastName: last,
                      );

                      if (!mounted) return;

                      firstNameController.clear();
                      lastNameController.clear();

                      setState(() {
                        expanded = false;
                      });

                      customDialog(
                        context: context,
                        title: isArabic ? "نجاح" : "Success",
                        message: isArabic
                            ? "تم تحديث الاسم بنجاح"
                            : "Your name has been updated successfully",
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
