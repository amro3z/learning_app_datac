import 'package:flutter/material.dart';

class DropdownOption {
  final String value;
  final String enLabel;
  final String arLabel;

  const DropdownOption({
    required this.value,
    required this.enLabel,
    required this.arLabel,
  });
}

class AppDropdownField extends StatelessWidget {
  final String? value;
  final bool isArabic;
  final String labelText;
  final List<DropdownOption> options;
  final ValueChanged<String?> onChanged;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.isArabic,
    required this.labelText,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value?.isEmpty == true ? null : value,
      dropdownColor: const Color(0xFF141722),
      iconEnabledColor: Colors.white70,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white70,
          fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7F5AF0)),
        ),
      ),
      style: TextStyle(
        color: Colors.white,
        fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
      ),
      items: options.map((item) {
        return DropdownMenuItem<String>(
          value: item.value,
          child: Text(isArabic ? item.arLabel : item.enLabel),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}


const List<DropdownOption> gradeOptions = [
  DropdownOption(
    value: 'FPGrade',
    enLabel: 'First Primary',
    arLabel: 'الأول الابتدائي',
  ),
  DropdownOption(
    value: 'SPGrade',
    enLabel: 'Second Primary',
    arLabel: 'الثاني الابتدائي',
  ),
  DropdownOption(
    value: 'TPGrade',
    enLabel: 'Third Primary',
    arLabel: 'الثالث الابتدائي',
  ),
  DropdownOption(
    value: 'FSGrade',
    enLabel: 'Fourth Primary',
    arLabel: 'الرابع الابتدائي',
  ),
  DropdownOption(
    value: 'SSGrade',
    enLabel: 'Fifth Primary',
    arLabel: 'الخامس الابتدائي',
  ),
  DropdownOption(
    value: 'TSGrade',
    enLabel: 'Sixth Primary',
    arLabel: 'السادس الابتدائي',
  ),
  DropdownOption(
    value: 'FHGrade',
    enLabel: 'First Preparatory',
    arLabel: 'الأول الإعدادي',
  ),
  DropdownOption(
    value: 'SHGrade',
    enLabel: 'Second Preparatory',
    arLabel: 'الثاني الإعدادي',
  ),
  DropdownOption(
    value: 'THGrade',
    enLabel: 'Third Preparatory',
    arLabel: 'الثالث الإعدادي',
  ),
  DropdownOption(
    value: 'FPHGrade',
    enLabel: 'First Secondary',
    arLabel: 'الأول الثانوي',
  ),
  DropdownOption(
    value: 'SPHGrade',
    enLabel: 'Second Secondary',
    arLabel: 'الثاني الثانوي',
  ),
  DropdownOption(
    value: 'TPHGrade',
    enLabel: 'Third Secondary',
    arLabel: 'الثالث الثانوي',
  ),
];

const List<DropdownOption> specializationOptions = [
  DropdownOption(value: 'arabic', enLabel: 'Arabic', arLabel: 'اللغة العربية'),
  DropdownOption(
    value: 'english',
    enLabel: 'English',
    arLabel: 'اللغة الإنجليزية',
  ),
  DropdownOption(value: 'math', enLabel: 'Mathematics', arLabel: 'الرياضيات'),
  DropdownOption(value: 'physics', enLabel: 'Physics', arLabel: 'الفيزياء'),
  DropdownOption(value: 'chemistry', enLabel: 'Chemistry', arLabel: 'الكيمياء'),
  DropdownOption(value: 'biology', enLabel: 'Biology', arLabel: 'الأحياء'),
  DropdownOption(value: 'history', enLabel: 'History', arLabel: 'التاريخ'),
  DropdownOption(
    value: 'geography',
    enLabel: 'Geography',
    arLabel: 'الجغرافيا',
  ),
  DropdownOption(
    value: 'computer_science',
    enLabel: 'Computer Science',
    arLabel: 'الحاسب الآلي',
  ),
];
