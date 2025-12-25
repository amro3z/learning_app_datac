class InstructorModel {
late int id;
  late String name;
  late String bio;
  late String photo;
  late Map<String, dynamic> socialLinks;

  InstructorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    bio = json['bio'];
    socialLinks = json['social_links'] ?? {};
  }
}