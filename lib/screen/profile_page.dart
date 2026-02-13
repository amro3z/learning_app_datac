import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/user_state.dart';
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
  bool notify = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            customDialog(
              context: context,
              title: "Error",
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
              onRefresh: () => context.read<UserCubit>().refreshUser(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: kToolbarHeight),
                      defaultText(text: "Profile", size: 24),
                      const SizedBox(height: 14),

                      ProfileCard(
                        pickImage: (ctx) => _pickImage(ctx),
                        state: state,
                      ),

                      const SizedBox(height: 16),

                      defaultText(text: "Settings", size: 16),
                      const SizedBox(height: 12),

                      /// 🔥 Edit Name Widget
                      const EditNameCard(),

                      const SizedBox(height: 12),

                      /// Notifications
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
                              text: "Notifications",
                              size: 16,
                              bold: false,
                              isCenter: false,
                            ),
                            const Spacer(),
                            Switch(
                              activeThumbColor: Colors.lightBlue,
                              activeTrackColor: Colors.blue.withOpacity(0.5),
                              value: notify,
                              onChanged: (val) {
                                setState(() {
                                  notify = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Delete Account
                     const DeleteAccountCard(),

                      const SizedBox(height: 12),

                      /// Logout
                      CustomGlowButton(
                        title: "Log out",
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
              ),
            );
          }

          if (state is UserError) {
            return const SizedBox();
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
