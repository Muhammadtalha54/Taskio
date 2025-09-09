import 'package:hive/hive.dart';
import 'package:todo_app_hive/models/tasksmodel.dart';

class HiveService {
  static final box = Hive.box<Task>('tasksBox');

  // Add a task
  static Future<void> addTask(Task task) async {
    await box.add(task);
  }

  // Get all tasks
  static List<Task> getTasks() {
    return box.values.toList();
  }

  // Update a task
  static Future<void> updateTask(Task task) async {
    await task.save();
  }

  // Delete a task
  static Future<void> deleteTask(Task task) async {
    await task.delete();
  }

  // Clear all tasks (optional)
  static Future<void> clearTasks() async {
    await box.clear();
  }
}
