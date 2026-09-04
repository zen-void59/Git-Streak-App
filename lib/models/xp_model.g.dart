// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class XpModelAdapter extends TypeAdapter<XpModel> {
  @override
  final int typeId = 1;

  @override
  XpModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return XpModel(
      totalXp: fields[0] as int? ?? 0,
      level: fields[1] as int? ?? 1,
      badges: (fields[2] as List?)?.cast<String>() ?? [],
      completedHabitsCount: fields[3] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, XpModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.totalXp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.badges)
      ..writeByte(3)
      ..write(obj.completedHabitsCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XpModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
