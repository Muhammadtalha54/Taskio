import 'package:flutter/material.dart';

class Animationprovider extends ChangeNotifier {
  // Calendar animations
  bool _calendarAnimated = false;

  // Task animations
  List<bool> _taskAnimated = [];
  List<bool> _taskDeletionAnimated = [];

  // Modal animations
  bool _modalVisible = false;

  // Selected date animation
  int _selectedDateIndex = -1;
  bool _dateSelectionAnimated = false;

  // Getters
  bool get calendarAnimated => _calendarAnimated;
  List<bool> get taskAnimated => _taskAnimated;
  List<bool> get taskDeletionAnimated => _taskDeletionAnimated;
  bool get modalVisible => _modalVisible;
  int get selectedDateIndex => _selectedDateIndex;
  bool get dateSelectionAnimated => _dateSelectionAnimated;

  /// Initialize all animations
  void initializeAnimations() {
    _calendarAnimated = false;
    _taskAnimated.clear();
    _taskDeletionAnimated.clear();
    _modalVisible = false;
    _selectedDateIndex = -1;
    _dateSelectionAnimated = false;
    notifyListeners();
  }

  /// Calendar animation control
  void setCalendarAnimated(bool value) {
    if (_calendarAnimated != value) {
      _calendarAnimated = value;
      notifyListeners();
    }
  }

  /// Task animations control
  void initTaskAnimations(int length) {
    if (_taskAnimated.length != length) {
      _taskAnimated = List.generate(length, (_) => false);
      _taskDeletionAnimated = List.generate(length, (_) => false);
    }
  }

  void setTaskAnimated(int index, bool value) {
    if (index >= 0 && index < _taskAnimated.length) {
      if (_taskAnimated[index] != value) {
        _taskAnimated[index] = value;
        notifyListeners();
      }
    }
  }

  void setTaskDeletionAnimated(int index, bool value) {
    if (index >= 0 && index < _taskDeletionAnimated.length) {
      if (_taskDeletionAnimated[index] != value) {
        _taskDeletionAnimated[index] = value;
        notifyListeners();
      }
    }
  }

  /// Date selection animation
  void setSelectedDateAnimation(int dateIndex, bool animated) {
    _selectedDateIndex = dateIndex;
    _dateSelectionAnimated = animated;
    notifyListeners();
  }

  /// Modal animation control
  void setModalVisible(bool value) {
    if (_modalVisible != value) {
      _modalVisible = value;
      notifyListeners();
    }
  }

  /// Reset specific animations
  void resetTaskAnimations() {
    if (_taskAnimated.isNotEmpty) {
      _taskAnimated = _taskAnimated.map((_) => false).toList();
      _taskDeletionAnimated = _taskDeletionAnimated.map((_) => false).toList();
      notifyListeners();
    }
  }

  void resetDateAnimation() {
    _selectedDateIndex = -1;
    _dateSelectionAnimated = false;
    notifyListeners();
  }

  /// Animation delays and durations
  Duration get calendarAnimationDuration => const Duration(milliseconds: 800);
  Duration get taskAnimationDuration => const Duration(milliseconds: 600);
  Duration get dateSelectionDuration => const Duration(milliseconds: 400);
  Duration get modalAnimationDuration => const Duration(milliseconds: 500);
  Duration get deletionAnimationDuration => const Duration(milliseconds: 300);

  /// Get staggered delay for task animations
  Duration getTaskAnimationDelay(int index) {
    return Duration(milliseconds: 150 * index);
  }

  /// Neon colors for tasks
  List<Color> get neonColors => [
    const Color(0xFF00F5FF), // Cyan
    const Color(0xFF39FF14), // Electric lime
    const Color(0xFFFF073A), // Electric red
    const Color(0xFFFF69B4), // Hot pink
    const Color(0xFF9D00FF), // Electric violet
    const Color(0xFFFFD700), // Electric gold
    const Color(0xFF00FF7F), // Spring green
    const Color(0xFFFF4500), // Orange red
  ];

  Color getNeonColorForTask(int index) {
    return neonColors[index % neonColors.length];
  }

  /// Soft glow colors for selection
  List<Color> get glowColors => [
    Colors.blueAccent.withOpacity(0.3),
    Colors.cyanAccent.withOpacity(0.3),
    Colors.purpleAccent.withOpacity(0.3),
    Colors.greenAccent.withOpacity(0.3),
    Colors.pinkAccent.withOpacity(0.3),
  ];

  Color getGlowColor(int index) {
    return glowColors[index % glowColors.length];
  }
}
