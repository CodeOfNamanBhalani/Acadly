import 'package:hive/hive.dart';

part 'notice_model.g.dart';

@HiveType(typeId: 5)
class NoticeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime datePosted;

  @HiveField(4)
  final String postedBy;

  @HiveField(5)
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'datePosted': datePosted.toIso8601String(),
      'postedBy': postedBy,
      'isImportant': isImportant,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map) {
    return NoticeModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      datePosted: DateTime.parse(map['datePosted'] as String),
      postedBy: map['postedBy'] as String,
      isImportant: map['isImportant'] as bool? ?? false,
    );
  }
}

