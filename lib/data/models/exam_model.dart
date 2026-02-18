
class ExamModel {
  final String id;
  final String examName;
  final String subject;
  final DateTime examDate;
  final String examTime;
  final String examLocation;
  final DateTime createdAt;
  final String? notes;

  ExamModel({
    required this.id,
    required this.examName,
    required this.subject,
    required this.examDate,
    required this.examTime,
    required this.examLocation,
    required this.createdAt,
    this.notes,
  });

  bool get isPast => DateTime.now().isAfter(examDate);

  Duration get timeRemaining => examDate.difference(DateTime.now());

  ExamModel copyWith({
    String? id,
    String? examName,
    String? subject,
    DateTime? examDate,
    String? examTime,
    String? examLocation,
    DateTime? createdAt,
    String? notes,
  }) {
    return ExamModel(
      id: id ?? this.id,
      examName: examName ?? this.examName,
      subject: subject ?? this.subject,
      examDate: examDate ?? this.examDate,
      examTime: examTime ?? this.examTime,
      examLocation: examLocation ?? this.examLocation,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  // Convert to API JSON format
  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'exam_type': examName,
      'exam_date': examDate.toIso8601String(),
      'room': examLocation,
      'notes': notes ?? '',
    };
  }

  // Create from API JSON response
  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id']?.toString() ?? '',
      examName: json['exam_type'] ?? '',
      subject: json['subject'] ?? '',
      examDate: DateTime.tryParse(json['exam_date'] ?? '') ?? DateTime.now(),
      examTime: _extractTimeFromDate(json['exam_date']),
      examLocation: json['room'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      notes: json['notes'],
    );
  }

  static String _extractTimeFromDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final dt = DateTime.parse(dateString);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  // Legacy methods for compatibility
  Map<String, dynamic> toMap() => toJson();
  factory ExamModel.fromMap(Map<String, dynamic> map) => ExamModel.fromJson(map);
}
