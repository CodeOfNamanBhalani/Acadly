// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamModelAdapter extends TypeAdapter<ExamModel> {
  @override
  final int typeId = 3;

  @override
  ExamModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamModel(
      id: fields[0] as String,
      examName: fields[1] as String,
      subject: fields[2] as String,
      examDate: fields[3] as DateTime,
      examTime: fields[4] as String,
      examLocation: fields[5] as String,
      userId: fields[6] as String,
      createdAt: fields[7] as DateTime,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExamModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.examName)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.examDate)
      ..writeByte(4)
      ..write(obj.examTime)
      ..writeByte(5)
      ..write(obj.examLocation)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

