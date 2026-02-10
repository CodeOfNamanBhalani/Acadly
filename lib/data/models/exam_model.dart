import 'package:hive/hive.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 3)
class ExamModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String examName;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final DateTime examDate;

  @HiveField(4)
  final String examTime;

  @HiveField(5)
  final String examLocation;

  @HiveField(6)
  final String userId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String? notes;

  ExamModel({
    required this.id,
    required this.examName,
    required this.subject,
    required this.examDate,
    required this.examTime,
    required this.examLocation,
    required this.userId,
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
    String? userId,
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
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examName': examName,
      'subject': subject,
      'examDate': examDate.toIso8601String(),
      'examTime': examTime,
      'examLocation': examLocation,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'] as String,
      examName: map['examName'] as String,
      subject: map['subject'] as String,
      examDate: DateTime.parse(map['examDate'] as String),
      examTime: map['examTime'] as String,
      examLocation: map['examLocation'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      notes: map['notes'] as String?,
    );
  }
}

