part of '../register_screen.dart';

extension _RegisterWidgets on _RegisterScreenState {
  Widget _card({required Widget child}) {
    return AnimatedBuilder(
      animation: _ambientAnimation,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(getScreenWidth(context) * 0.06154),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E).withOpacity(0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(
                0xFF4FACFE,
              ).withOpacity(0.15 * _ambientAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF7F5AF0,
                ).withOpacity(0.08 * _ambientAnimation.value),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _roleSelector(bool isArabic) {
    return Container(
      padding: EdgeInsets.all(getScreenWidth(context) * 0.01538),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / 2;
          
          final Alignment alignment = _selectedRole == AccountRole.student
              ? (isArabic ? Alignment.centerRight : Alignment.centerLeft)
              : (isArabic ? Alignment.centerLeft : Alignment.centerRight);

          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.elasticOut, 
                alignment: alignment,
                child: Container(
                  width: width - 4,
                  height: getScreenHeight(context) * 0.06000,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FACFE).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _roleItem(
                      isArabic: isArabic,
                      title: isArabic ? 'طالب' : 'Student',
                      icon: Icons.school_rounded,
                      selected: _selectedRole == AccountRole.student,
                      onTap: () =>
                          setState(() => _selectedRole = AccountRole.student),
                    ),
                  ),
                  SizedBox(width: getScreenWidth(context) * 0.01538),
                  Expanded(
                    child: _roleItem(
                      isArabic: isArabic,
                      title: isArabic ? 'مدرس' : 'Instructor',
                      icon: Icons.workspace_premium_rounded,
                      selected: _selectedRole == AccountRole.instructor,
                      onTap: () => setState(
                        () => _selectedRole = AccountRole.instructor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _roleItem({
    required bool isArabic,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: getScreenHeight(context) * 0.01750, horizontal: getScreenWidth(context) * 0.02051),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.white.withOpacity(0.5),
              size: getScreenWidth(context) * 0.05128,
            ),
            SizedBox(width: getScreenWidth(context) * 0.02051),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: getScreenWidth(context) * 0.03590,
                fontFamily: isArabic ? 'CustomArabicFont' : 'CustomEnglishFont',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentFields(bool isArabic) {
    return Column(
      key: const ValueKey(AccountRole.student),
      children: [
        AppDropdownField(
          value: _gradeController.text.isEmpty ? null : _gradeController.text,
          isArabic: isArabic,
          labelText: isArabic ? 'الصف الدراسي' : 'Grade',
          options: gradeOptions,
          onChanged: (value) {
            setState(() {
              _gradeController.text = value ?? '';
            });
          },
        ),
        SizedBox(height: getScreenHeight(context) * 0.018),
        CustomFormTextField(
          controller: _parentPhoneController,
          labelText: isArabic ? 'رقم ولي الأمر' : 'Parent Phone',
          keyboardType: CustomTextFieldType.phone,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          
        ),
      ],
    );
  }

  Widget _instructorFields(bool isArabic) {
    return Column(
      key: const ValueKey(AccountRole.instructor),
      children: [
        AppDropdownField(
          value: _specializationController.text.isEmpty
              ? null
              : _specializationController.text,
          isArabic: isArabic,
          labelText: isArabic ? 'التخصص' : 'Specialization',
          options: specializationOptions,
          onChanged: (value) {
            setState(() {
              _specializationController.text = value ?? '';
            });
          },
        ),
        SizedBox(height: getScreenHeight(context) * 0.018),
      ],
    );
  }
}
