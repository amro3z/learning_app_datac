import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      initialData: {
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
          padding: const EdgeInsets.all(16),
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
                  fontSize: 14,
                  fontFamily: isArabic
                      ? 'CustomArabicFont'
                      : 'CustomEnglishFont',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildRequirementRow(
                isArabic ? 'على الأقل 8 أحرف' : 'At least 8 characters',
                length,
                isArabic,
              ),
              _buildRequirementRow(
                isArabic ? 'بدون مسافات' : 'No spaces',
                noSpace,
                isArabic,
              ),
              _buildRequirementRow(
                isArabic
                    ? 'حروف كبيرة وصغيرة (A-Z و a-z)'
                    : 'Both uppercase and lowercase letters',
                upperLower,
                isArabic,
              ),
              _buildRequirementRow(
                isArabic
                    ? 'رمز خاص واحد على الأقل (!@#\$%^&*...)'
                    : 'At least 1 special character',
                special,
                isArabic,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirementRow(String text, bool isMet, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isMet ? Colors.green : Colors.red,
                fontSize: 13,
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
