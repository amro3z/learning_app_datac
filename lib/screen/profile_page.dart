import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:training/services/directus_user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  bool _isUploading = false;

  final ApiService _api = ApiService();

  Future<Map<String, String>> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "token": prefs.getString("access_token") ?? "",
      "userId": prefs.getString("user_id") ?? "",
    };
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final imageFile = File(picked.path);

    setState(() {
      _profileImage = imageFile;
      _isUploading = true;
    });

    final auth = await _getAuthData();

    final upload = await _api.uploadProfileImage(
      image: imageFile,
      accessToken: auth["token"]!,
    );

    if (upload["success"]) {
      await _api.updateUserAvatar(
        userId: auth["userId"]!,
        fileId: upload["fileId"],
        accessToken: auth["token"]!,
      );
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profileCard(),
          const SizedBox(height: 24),
          _myCoursesSection(),
        ],
      ),
    );
  }

  // ================= PROFILE CARD =================
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.blueAccent,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage(
                                'assets/images/pro2.jpeg',
                              )
                              as ImageProvider,
                  ),
                ),
                if (_isUploading)
                  const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Alex Anderson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'alex.anderson@email.com',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatItem(value: '3', label: 'Enrolled', color: Colors.blue),
              _StatItem(value: '0', label: 'Completed', color: Colors.purple),
              _StatItem(value: '24', label: 'Hours', color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MY COURSES =================
  Widget _myCoursesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Courses (3)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _courseCard(
          title: 'Complete Web Development Bootcamp',
          progress: 0.45,
          image: 'assets/images/pro1.jpg',
        ),
        _courseCard(
          title: 'UI/UX Design Masterclass',
          progress: 0.20,
          image: 'assets/images/pro1.jpg',
        ),
        _courseCard(
          title: 'Business Analytics & Data Science',
          progress: 0.60,
          image: 'assets/images/pro1.jpg',
        ),
      ],
    );
  }

  Widget _courseCard({
    required String title,
    required double progress,
    required String image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, width: 52, height: 52, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF7C6CFF)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% complete',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// ================= STAT ITEM =================
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
