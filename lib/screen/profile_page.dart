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
  final ApiService _api = ApiService();

  File? _profileImage;
  bool _isUploading = false;
  bool _loadingUser = true;

  String? _name;
  String? _email;
  String? _avatarId;

  // ================= AUTH =================
  Future<Map<String, String>> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "token": prefs.getString("access_token") ?? "",
      "userId": prefs.getString("user_id") ?? "",
    };
  }

  // ================= LOAD USER =================
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = await _getAuthData();

    if (auth["token"]!.isEmpty) {
      setState(() => _loadingUser = false);
      return;
    }

    final res = await _api.getCurrentUser(accessToken: auth["token"]!);

    if (!mounted) return;

    if (res["success"]) {
      final user = res["user"];
      setState(() {
        _name = '${user["first_name"] ?? ""} ${user["last_name"] ?? ""}'.trim();
        _email = user["email"];
        _avatarId = user["avatar"];
        _loadingUser = false;
      });
    } else {
      setState(() => _loadingUser = false);
    }
  }

  // ================= PICK & UPLOAD IMAGE =================
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

      // 🔁 reload user to get new avatar
      await _loadUser();
    }

    setState(() => _isUploading = false);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                  backgroundColor: const Color(0xFF7C6CFF),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_avatarId != null
                                  ? NetworkImage(
                                      'https://e-learning-directus.csiwm3.easypanel.host/assets/$_avatarId',
                                    )
                                  : null)
                              as ImageProvider?,
                    child: (_profileImage == null && _avatarId == null)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          )
                        : null,
                  ),
                ),
                if (_isUploading)
                  const CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(_email ?? '', style: const TextStyle(color: Colors.grey)),
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
        _courseCard(title: 'Complete Web Development Bootcamp', progress: 0.45),
        _courseCard(title: 'UI/UX Design Masterclass', progress: 0.20),
        _courseCard(title: 'Business Analytics & Data Science', progress: 0.60),
      ],
    );
  }

  Widget _courseCard({required String title, required double progress}) {
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade800,
            ),
            child: const Icon(Icons.play_circle, color: Colors.white),
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
