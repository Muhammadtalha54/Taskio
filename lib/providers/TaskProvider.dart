import 'package:flutter/material.dart';
import 'package:todo_app_hive/models/tasksmodel.dart';
import 'package:todo_app_hive/service.dart/NotificationService.dart';
import 'package:todo_app_hive/service.dart/hiveservice.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _showAllTasks = false;
  bool _isLoading = false;

  // Getters
  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;
  bool get showAllTasks => _showAllTasks;
  bool get isLoading => _isLoading;

  /// Load all tasks from Hive database
  Future<void> loadTasks() async {
    try {
      _isLoading = true;
      notifyListeners();

      _tasks = HiveService.getTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    try {
      // Validate task
      if (task.title.trim().isEmpty) {
        throw Exception('Task title cannot be empty');
      }

      // Add to Hive
      await HiveService.addTask(task);

      // Schedule notification if task has future due date
      if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
        await _scheduleTaskNotification(task);
      }

      // Reload tasks to get updated list
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(Task task) async {
    try {
      // Delete from Hive
      await HiveService.deleteTask(task);

      // Cancel any scheduled notification
      await NotificationService.cancelNotification(task.hashCode);

      // Reload tasks
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle task completion status
  Future<void> toggleComplete(Task task) async {
    try {
      // Update task completion status
      task.isCompleted = !task.isCompleted;

      // Update in Hive
      await HiveService.updateTask(task);

      // Cancel notification if task is completed
      if (task.isCompleted) {
        await NotificationService.cancelNotification(task.hashCode);
      } else if (task.dueDate != null &&
          task.dueDate!.isAfter(DateTime.now())) {
        // Reschedule notification if task is uncompleted and has future due date
        await _scheduleTaskNotification(task);
      }

      // Update UI
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      await HiveService.updateTask(task);

      // Update notification
      await NotificationService.cancelNotification(task.hashCode);
      if (task.dueDate != null &&
          task.dueDate!.isAfter(DateTime.now()) &&
          !task.isCompleted) {
        await _scheduleTaskNotification(task);
      }

      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  /// Get tasks for a specific date
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;

      final taskDate = task.dueDate!;
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    }).toList();
  }

  /// Get completed tasks
  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  /// Get pending tasks
  List<Task> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  /// Get overdue tasks
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.isCompleted || task.dueDate == null) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }

  /// Get today's tasks
  List<Task> get todayTasks {
    final today = DateTime.now();
    return getTasksForDate(today);
  }

  /// Set selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      _showAllTasks = false;
      notifyListeners();
    }
  }

  /// Toggle show all tasks
  void toggleShowAllTasks() {
    _showAllTasks = !_showAllTasks;
    notifyListeners();
  }

  /// Set show all tasks state
  void setShowAllTasks(bool value) {
    if (_showAllTasks != value) {
      _showAllTasks = value;
      notifyListeners();
    }
  }

  /// Get task statistics
  Map<String, int> get taskStats {
    return {
      'total': _tasks.length,
      'completed': completedTasks.length,
      'pending': pendingTasks.length,
      'overdue': overdueTasks.length,
    };
  }

  /// Search tasks by title
  List<Task> searchTasks(String query) {
    if (query.trim().isEmpty) return _tasks;

    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Private helper method to schedule task notification
  Future<void> _scheduleTaskNotification(Task task) async {
    try {
      await NotificationService.showAlarmNotification(
        id: task.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: task.dueDate!,
      );
    } catch (e) {
      // Log error but don't throw - notification failure shouldn't break task creation
      debugPrint(
        'Failed to schedule notification for task: ${task.title}. Error: $e',
      );
    }
  }

  /// Clear all completed tasks
  Future<void> clearCompletedTasks() async {
    try {
      final completedTasksList = completedTasks;

      for (final task in completedTasksList) {
        await HiveService.deleteTask(task);
        await NotificationService.cancelNotification(task.hashCode);
      }

      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  /// Mark all tasks as completed
  Future<void> markAllAsCompleted() async {
    try {
      for (final task in pendingTasks) {
        task.isCompleted = true;
        await HiveService.updateTask(task);
        await NotificationService.cancelNotification(task.hashCode);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
