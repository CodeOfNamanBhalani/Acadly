import 'package:hive/hive.dart';

part 'assignment_model.g.dart';

@HiveType(typeId: 2)
class AssignmentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final String priority;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String userId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final int? customReminderMinutes;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.userId,
    required this.createdAt,
    this.description,
    this.customReminderMinutes,
  });

  bool get isCompleted => status == 'Completed';
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);

  AssignmentModel copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? dueDate,
    String? priority,
    String? status,
    String? userId,
    DateTime? createdAt,
    String? description,
    int? customReminderMinutes,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      customReminderMinutes: customReminderMinutes ?? this.customReminderMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'customReminderMinutes': customReminderMinutes,
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subject: map['subject'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: map['priority'] as String,
      status: map['status'] as String,
      userId: map['userId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      description: map['description'] as String?,
      customReminderMinutes: map['customReminderMinutes'] as int?,
    );
  }
}

