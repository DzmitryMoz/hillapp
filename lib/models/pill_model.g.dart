// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pill_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PillModelAdapter extends TypeAdapter<PillModel> {
  @override
  final int typeId = 1;

  @override
  PillModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PillModel(
      name: fields[0] as String,
      dose: fields[1] as double,
      date: fields[2] as DateTime,
      type: fields[3] as PillType,
    );
  }

  @override
  void write(BinaryWriter writer, PillModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dose)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PillTypeAdapter extends TypeAdapter<PillType> {
  @override
  final int typeId = 0;

  @override
  PillType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PillType.single;
      case 1:
        return PillType.course;
      case 2:
        return PillType.morning;
      case 3:
        return PillType.evening;
      default:
        return PillType.single;
    }
  }

  @override
  void write(BinaryWriter writer, PillType obj) {
    switch (obj) {
      case PillType.single:
        writer.writeByte(0);
        break;
      case PillType.course:
        writer.writeByte(1);
        break;
      case PillType.morning:
        writer.writeByte(2);
        break;
      case PillType.evening:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PillTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
