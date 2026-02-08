import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/custom_glow_buttom.dart';
import 'package:training/widgets/profile_card.dart';
import 'package:training/widgets/profile_course_card.dart';

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
        listenWhen: (prev, curr) => curr is UserLoaded && curr.message != null,
        listener: (context, state) {
          if (state is UserLoaded && state.message != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<UserCubit>().refreshUser(
                message: "Profile refreshed",
              ),
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
                        pickImage: (BuildContext ctx) => _pickImage(ctx),
                        state: state,
                      ),
                      const SizedBox(height: 12),
                      defaultText(text: "My Courses (3)", size: 16),
                      const SizedBox(height: 12),
                      ListView.builder(
                        itemBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: ProfileCourseCard(),
                          );
                        },
                        itemCount: 3,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                      ),

                      defaultText(text: "Settings", size: 16),
                      const SizedBox(height: 12),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.5),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(812),
                        ),
                        child: defaultText(
                          text: "Delete Account",
                          size: 16,
                          bold: false,
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 12),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserCubit>().logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Login again'),
                  ),
                ],
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
