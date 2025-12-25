class EnrollmentModel {
  late int id;
  late int userId; 
  late int courseId;
  late int progressPercent;
  late DateTime dateEnrolled;

  EnrollmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user'];
    courseId = json['course'];
    progressPercent = json['progress_percent'] ?? 0;
    dateEnrolled = DateTime.parse(json['date_enrolled']);
  }
}
