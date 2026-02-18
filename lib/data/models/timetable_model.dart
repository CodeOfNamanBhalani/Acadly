class TimetableModel {
  final String id;
  final String subjectName;
  final String facultyName;
  final int dayOfWeek; // 0 = Monday, 6 = Sunday
  final String startTime; // Format: "HH:mm"
  final String endTime; // Format: "HH:mm"
  final String roomNumber;

  static const List<String> dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  TimetableModel({
    required this.id,
    required this.subjectName,
    required this.facultyName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  TimetableModel copyWith({
    String? id,
    String? subjectName,
    String? facultyName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? roomNumber,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      facultyName: facultyName ?? this.facultyName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomNumber: roomNumber ?? this.roomNumber,
    );
  }

  String get dayName => dayNames[dayOfWeek];

  // Convert to API JSON format - API expects day as string like "Monday"
  Map<String, dynamic> toJson() {
    return {
      'subject': subjectName,
      'day': dayName, // Send as string "Monday", "Tuesday", etc.
      'start_time': startTime,
      'end_time': endTime,
      'room': roomNumber,
      'teacher': facultyName,
    };
  }

  // Create from API JSON response
  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    // Parse day - API returns string like "Monday"
    int dayIndex = 0;
    final dayValue = json['day'];
    if (dayValue is int) {
      dayIndex = dayValue;
    } else if (dayValue is String) {
      dayIndex = dayNames.indexWhere((d) => d.toLowerCase() == dayValue.toLowerCase());
      if (dayIndex == -1) dayIndex = 0;
    }

    return TimetableModel(
      id: json['id']?.toString() ?? '',
      subjectName: json['subject'] ?? '',
      facultyName: json['teacher'] ?? '',
      dayOfWeek: dayIndex,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      roomNumber: json['room'] ?? '',
    );
  }

  // Legacy methods for compatibility
  Map<String, dynamic> toMap() => toJson();
  factory TimetableModel.fromMap(Map<String, dynamic> map) => TimetableModel.fromJson(map);
}

