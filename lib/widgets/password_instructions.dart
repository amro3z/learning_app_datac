import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/helper/base.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/language_cubit_state.dart';

class PasswordInstructions extends StatelessWidget {
  final Stream<Map<String, bool>> passwordStream;

  const PasswordInstructions({super.key, required this.passwordStream});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;

    final isArabic =
        langState is LanguageCubitLoaded && langState.languageCode == 'ar';

    return StreamBuilder<Map<String, bool>>(
      stream: passwordStream,
      initialData: const {
        "length": false,
        "noSpace": true,
        "upperLower": false,
        "special": false,
      },
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};

        final length = data["length"] ?? false;
        final noSpace = data["noSpace"] ?? true;
        final upperLower = data["upperLower"] ?? false;
        final special = data["special"] ?? false;

        return Container(
          padding: EdgeInsets.all(getScreenWidth(context) * 0.04103),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic
                    ? 'كلمة المرور يجب أن تحتوي على:'
                    : 'Password must contain:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getScreenWidth(context) * 0.03590,
                  fontFamily: isArabic
                      ? 'CustomArabicFont'
                      : 'CustomEnglishFont',
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: getScreenHeight(context) * 0.01500),

              _buildRequirementRow(
                context: context,
                text: isArabic ? 'على الأقل 8 أحرف' : 'At least 8 characters',
                isMet: length,
                isArabic: isArabic,
              ),

              _buildRequirementRow(
                context: context,
                text: isArabic ? 'بدون مسافات' : 'No spaces',
                isMet: noSpace,
                isArabic: isArabic,
              ),

              _buildRequirementRow(
                context: context,
                text: isArabic
                    ? 'حروف كبيرة وصغيرة (A-Z و a-z)'
                    : 'Both uppercase and lowercase letters',
                isMet: upperLower,
                isArabic: isArabic,
              ),

              _buildRequirementRow(
                context: context,
                text: isArabic
                    ? 'رمز خاص واحد على الأقل (!@#\$%^&*...)'
                    : 'At least 1 special character',
                isMet: special,
                isArabic: isArabic,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirementRow({
    required BuildContext context,
    required String text,
    required bool isMet,
    required bool isArabic,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: getScreenWidth(context) * 0.05128,
          ),

          SizedBox(width: getScreenWidth(context) * 0.02564),

          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? Colors.green : Colors.red,
                fontSize: getScreenWidth(context) * 0.03333,
                fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}
