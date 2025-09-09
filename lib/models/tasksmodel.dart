import 'package:hive/hive.dart';
part 'tasksmodel.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime? dueDate;

  @HiveField(2)
  bool isCompleted;

  Task({required this.title, this.dueDate, this.isCompleted = false});
}
