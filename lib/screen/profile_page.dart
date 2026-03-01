import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/language_cubit.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/cubits/states/language_cubit_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/helper/massage_dialog.dart';
import 'package:training/widgets/delete_account_card.dart';
import 'package:training/widgets/profile_card.dart';
import 'package:training/widgets/edit_name_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notify = true; // مفعلة افتراضياً

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notify = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LanguageCubit>().state;
    final languageCode = langState is LanguageCubitLoaded
        ? langState.languageCode
        : 'en';

    return Scaffold(
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            customDialog(
              context: context,
              title: languageCode == 'ar' ? "خطأ" : "Error",
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<UserCubit>().refreshUser();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: kToolbarHeight),

                    defaultText(
                      context: context,
                      text: languageCode == 'ar' ? "الملف الشخصي" : "Profile",
                      size: 24,
                    ),

                    const SizedBox(height: 14),

                    ProfileCard(
                      pickImage: (ctx) => _pickImage(ctx),
                      state: state,
                    ),

                    const SizedBox(height: 16),

                    defaultText(
                      context: context,
                      text: languageCode == 'ar' ? "الإعدادات" : "Settings",
                      size: 16,
                    ),

                    const SizedBox(height: 12),

                    const EditNameCard(),

                    const SizedBox(height: 12),

                    /// Notifications Toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          defaultText(
                            context: context,
                            text: languageCode == 'ar'
                                ? "الإشعارات"
                                : "Notifications",
                            size: 16,
                            isCenter: false,
                          ),
                          const Spacer(),
                          Switch(
                            value: notify,
                            onChanged: (val) async {
                              setState(() {
                                notify = val;
                              });
                              await _saveNotificationPreference(val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Language
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          context.read<LanguageCubit>().toggle();
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.language, color: Colors.lightBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: defaultText(
                                context: context,
                                text: languageCode == 'ar'
                                    ? "تغيير اللغة"
                                    : "Change Language",
                                size: 16,
                                isCenter: false,
                              ),
                            ),
                            defaultText(
                              context: context,
                              text: languageCode == 'ar'
                                  ? "العربية"
                                  : "English",
                              size: 13,
                              color: Colors.lightBlue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const DeleteAccountCard(),

                    const SizedBox(height: 12),

                    CustomGlowButton(
                      title: languageCode == 'ar' ? "تسجيل الخروج" : "Log out",
                      onPressed: () {
                        context.read<UserCubit>().logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      width: double.infinity,
                    ),

                    SizedBox(height: kBottomNavigationBarHeight + 30),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    context.read<UserCubit>().uploadAvatar(File(picked.path));
  }
}
