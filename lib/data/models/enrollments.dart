class EnrollmentModel {
  late int id;
  late String userId;
  late int courseId;
  late double progressPercent;
  late DateTime dateEnrolled;

  EnrollmentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user'];
    courseId = json['course'];
    progressPercent = (json['progress_percent'] ?? 0 as num).toDouble();
    dateEnrolled = DateTime.parse(json['date_enrolled']);
  }
}
