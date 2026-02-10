import 'package:hive/hive.dart';

part 'timetable_model.g.dart';

@HiveType(typeId: 1)
class TimetableModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectName;

  @HiveField(2)
  final String facultyName;

  @HiveField(3)
  final int dayOfWeek; // 0 = Monday, 6 = Sunday

  @HiveField(4)
  final String startTime; // Format: "HH:mm"

  @HiveField(5)
  final String endTime; // Format: "HH:mm"

  @HiveField(6)
  final String roomNumber;

  @HiveField(7)
  final String userId;

  TimetableModel({
    required this.id,
    required this.subjectName,
    required this.facultyName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
    required this.userId,
  });

  TimetableModel copyWith({
    String? id,
    String? subjectName,
    String? facultyName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? roomNumber,
    String? userId,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      subjectName: subjectName ?? this.subjectName,
      facultyName: facultyName ?? this.facultyName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      roomNumber: roomNumber ?? this.roomNumber,
      userId: userId ?? this.userId,
    );
  }

  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectName': subjectName,
      'facultyName': facultyName,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'roomNumber': roomNumber,
      'userId': userId,
    };
  }

  factory TimetableModel.fromMap(Map<String, dynamic> map) {
    return TimetableModel(
      id: map['id'] as String,
      subjectName: map['subjectName'] as String,
      facultyName: map['facultyName'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      roomNumber: map['roomNumber'] as String,
      userId: map['userId'] as String,
    );
  }
}

