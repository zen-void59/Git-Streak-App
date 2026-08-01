import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  int days;

  @HiveField(2)
  bool completed;


  HabitModel({
    required this.name,
    required this.days,
    required this.completed,
  });

}