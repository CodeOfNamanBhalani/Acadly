// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableModelAdapter extends TypeAdapter<TimetableModel> {
  @override
  final int typeId = 1;

  @override
  TimetableModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableModel(
      id: fields[0] as String,
      subjectName: fields[1] as String,
      facultyName: fields[2] as String,
      dayOfWeek: fields[3] as int,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      roomNumber: fields[6] as String,
      userId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectName)
      ..writeByte(2)
      ..write(obj.facultyName)
      ..writeByte(3)
      ..write(obj.dayOfWeek)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.roomNumber)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

