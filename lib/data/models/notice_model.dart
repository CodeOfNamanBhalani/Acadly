class NoticeModel {
  final String id;
  final String title;
  final String description;
  final DateTime datePosted;
  final String postedBy;
  final bool isImportant;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.datePosted,
    required this.postedBy,
    this.isImportant = false,
  });

  NoticeModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? datePosted,
    String? postedBy,
    bool? isImportant,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      datePosted: datePosted ?? this.datePosted,
      postedBy: postedBy ?? this.postedBy,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'posted_by': postedBy,
      'is_important': isImportant,
    };
  }

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      datePosted: DateTime.tryParse(json['date_posted'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      postedBy: json['posted_by'] ?? '',
      isImportant: json['is_important'] ?? false,
    );
  }

  // Legacy methods for compatibility
  Map<String, dynamic> toMap() => toJson();
  factory NoticeModel.fromMap(Map<String, dynamic> map) => NoticeModel.fromJson(map);
}
