import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/states/user_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                message: "تم تحديث البيانات",
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 24),
                  SizedBox(height: kToolbarHeight),
                  _profileCard(context, state),
                ],
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

  Widget _profileCard(BuildContext context, UserLoaded state) {
    return Column(
      children: [
        GestureDetector(
          onTap: state.isUploading ? null : () => _pickImage(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: state.avatarUrl != null
                    ? NetworkImage(state.avatarUrl!)
                    : null,
                child: state.avatarUrl == null
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
              if (state.isUploading)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          state.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(state.email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    context.read<UserCubit>().uploadAvatar(File(picked.path));
  }
}
