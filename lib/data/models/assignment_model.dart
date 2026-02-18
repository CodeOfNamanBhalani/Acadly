class AssignmentModel {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final String priority;
  final String status;
  final DateTime createdAt;
  final String? description;
  final int? customReminderMinutes;

  AssignmentModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    required this.status,
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
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      customReminderMinutes: customReminderMinutes ?? this.customReminderMinutes,
    );
  }

  // Convert to API JSON format
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'description': description ?? '',
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
    };
  }

  // Create from API JSON response
  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      dueDate: DateTime.tryParse(json['due_date'] ?? '') ?? DateTime.now(),
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      description: json['description'],
      customReminderMinutes: json['custom_reminder_minutes'],
    );
  }

  // Legacy methods for compatibility
  Map<String, dynamic> toMap() => toJson();
  factory AssignmentModel.fromMap(Map<String, dynamic> map) => AssignmentModel.fromJson(map);
}
