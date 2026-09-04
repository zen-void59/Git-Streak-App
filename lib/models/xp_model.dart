import 'package:hive/hive.dart';

part 'xp_model.g.dart';

@HiveType(typeId: 1)
class XpModel extends HiveObject {
  @HiveField(0)
  int totalXp;

  @HiveField(1)
  int level;

  @HiveField(2)
  List<String> badges;

  @HiveField(3)
  int completedHabitsCount;

  XpModel({
    this.totalXp = 0,
    this.level = 1,
    List<String>? badges,
    this.completedHabitsCount = 0,
  }) : badges = badges ?? [];
}
