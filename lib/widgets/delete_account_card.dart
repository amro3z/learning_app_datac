import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/helper/base.dart';
import 'package:training/helper/massage_dialog.dart';

class DeleteAccountCard extends StatelessWidget {
  const DeleteAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        customDialog(
          context: context,
          title: "Confirm Delete",
          message: "Are you sure you want to delete your account permanently?",
          onClose: () async {
            Navigator.of(context).pop();

            final success = await context.read<UserCubit>().deleteAccount();

            if (!context.mounted) return;

            if (success) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            } else {
              customDialog(
                context: context,
                title: "Error",
                message: "Failed to delete account",
              );
            }
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          border: Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(812),
        ),
        child: defaultText(
          text: "Delete Account",
          size: 16,
          bold: false,
          color: Colors.red,
          isCenter: false,
        ),
      ),
    );
  }
}
