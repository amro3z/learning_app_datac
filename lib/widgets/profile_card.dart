import 'package:flutter/material.dart';
import 'package:training/cubits/states/user_state.dart';
import 'package:training/helper/base.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.state, required this.pickImage});
  final UserLoaded state;
  final Future<void> Function(BuildContext) pickImage;
  @override
  Widget build(BuildContext context) {
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
              GestureDetector(
                onTap: state.isUploading
                    ? null
                    : () => pickImage(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.35),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 2),
                      ),
                    ),

                    // Avatar
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: state.avatarUrl != null
                          ? NetworkImage(state.avatarUrl!)
                          : null,
                      child: state.avatarUrl == null
                          ? const Icon(Icons.person, size: 32)
                          : null,
                    ),

                    // Uploading overlay
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
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultText(
                    text: state.name,
                    size: 20,
                    bold: true,
                    isCenter: false,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: state.email,
                    size: 14,
                    color: Colors.grey,
                    isCenter: false,
                    bold: false,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 32, color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  defaultText(
                    text: "12",
                    size: 16,
                    bold: false,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: "Enrolled",
                    size: 14,
                    color: Colors.grey,
                    bold: false,
                  ),
                ],
              ),
              Column(
                children: [
                  defaultText(
                    text: "0",
                    size: 16,
                    bold: false,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: "Completed",
                    size: 14,
                    color: Colors.grey,
                    bold: false,
                  ),
                ],
              ),
              Column(
                children: [
                  defaultText(
                    text: "24",
                    size: 16,
                    bold: false,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 4),
                  defaultText(
                    text: "Hours",
                    size: 14,
                    color: Colors.grey,
                    bold: false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
