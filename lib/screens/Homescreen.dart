import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_hive/models/tasksmodel.dart';
import 'package:todo_app_hive/providers/Animationprovider.dart';
import 'package:todo_app_hive/providers/TaskProvider.dart';
import 'package:todo_app_hive/screens/modalcomponent.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controllers for user input
  final TextEditingController _taskController = TextEditingController();

  // State variables
  DateTime? _selectedDateTime;
  DateTime _selectedDate = DateTime.now();
  bool _showAllTasks = false;

  // Animation Controllers - for built-in flutter animations
  late AnimationController _calendarController;
  late AnimationController _fabController;
  late Animation<Offset> _calendarSlideAnimation;
  late Animation<double> _calendarFadeAnimation;
  late Animation<double> _fabScaleAnimation;

  // Screen dimensions - calculated in build method
  late double height;
  late double width;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  /// Initialize Flutter's built-in animation controllers
  void _initializeAnimations() {
    // Calendar entrance animation
    _calendarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // FAB entrance animation
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Calendar slide animation from top
    _calendarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _calendarController, curve: Curves.elasticOut),
    );

    // Calendar fade animation
    _calendarFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _calendarController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // FAB scale animation
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
  }

  /// Load initial data and start entrance animations
  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Load tasks from storage
      taskProvider.loadTasks();

      // Start calendar animation immediately
      _calendarController.forward();

      // Start FAB animation with delay for better UX
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _fabController.forward();
      });
    });
  }

  @override
  void dispose() {
    // Clean up animation controllers
    _calendarController.dispose();
    _fabController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen dimensions
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              children: [
                _buildHeader(),
                _buildAnimatedCalendar(),
                _buildTaskToggleSection(),
                _buildTaskList(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(),
    );
  }

  // ============ UI BUILDING METHODS ============

  /// Creates the gradient background decoration
  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8F4FD),
          Color(0xFFF1F8FF),
          Color(0xFFE3F2FD),
          Color(0xFFF8FBFF),
        ],
        stops: [0.0, 0.3, 0.7, 1.0],
      ),
    );
  }

  /// Builds the app header with title
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Column(
        children: [
          // Animated title with scale effect
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.08,
                    vertical: height * 0.015,
                  ),
                  decoration: _buildNeumorphicDecoration(),
                  child: Text(
                    'My Tasks',
                    style: TextStyle(
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3748),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: height * 0.02),
        ],
      ),
    );
  }

  /// Builds the animated calendar section
  Widget _buildAnimatedCalendar() {
    return SlideTransition(
      position: _calendarSlideAnimation,
      child: FadeTransition(
        opacity: _calendarFadeAnimation,
        child: Container(
          height: height * 0.14,
          margin: EdgeInsets.symmetric(vertical: height * 0.01),
          child: _buildCalendarList(),
        ),
      ),
    );
  }

  /// Builds the horizontal calendar list
  Widget _buildCalendarList() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final date = DateTime(now.year, now.month, index + 1);
        return CalendarDay(
          date: date,
          selectedDate: _selectedDate,
          onDateSelected: _selectDate,
          animationIndex: index,
        );
      },
    );
  }

  /// Builds the task toggle section (Show All/Show Date Tasks)
  Widget _buildTaskToggleSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: _buildNeumorphicDecoration(
              depth: _showAllTasks ? 3 : 1,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(width * 0.04),
                onTap: _toggleShowAllTasks,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.015,
                  ),
                  child: Text(
                    _showAllTasks ? 'Show Date Tasks' : 'Show All Tasks',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w600,
                      color:
                          _showAllTasks
                              ? const Color(0xFF4299E1)
                              : const Color(0xFF2D3748),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main task list section
  Widget _buildTaskList() {
    return Expanded(
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Get tasks based on current filter
          final displayedTasks =
              _showAllTasks
                  ? taskProvider.tasks
                  : taskProvider.getTasksForDate(_selectedDate);

          if (displayedTasks.isEmpty) {
            return _buildEmptyState();
          }

          return _buildAnimatedTaskList(displayedTasks);
        },
      ),
    );
  }

  /// Builds the empty state when no tasks are found
  Widget _buildEmptyState() {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: EdgeInsets.all(width * 0.08),
              decoration: _buildNeumorphicDecoration(isInverted: true),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: width * 0.15,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    'No tasks found',
                    style: TextStyle(
                      fontSize: width * 0.045,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    'Tap the + button to add a task',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the animated task list with Provider integration
  Widget _buildAnimatedTaskList(List<Task> tasks) {
    return Consumer<Animationprovider>(
      builder: (context, animProvider, child) {
        // Initialize animations for current tasks (using Animationprovider)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          animProvider.initTaskAnimations(tasks.length);
        });

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskCard(
              task: tasks[index],
              index: index,
              onToggleComplete: () => _toggleTaskComplete(tasks[index]),
              onDelete: () => _deleteTask(tasks[index], index),
            );
          },
        );
      },
    );
  }

  /// Builds the animated floating action button
  Widget _buildAnimatedFAB() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.04),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4299E1).withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-4, -4),
              blurRadius: 15,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddTaskModal,
          backgroundColor: const Color(0xFF4299E1),
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.04),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF63B3ED),
                  Color(0xFF4299E1),
                  Color(0xFF3182CE),
                ],
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  /// Creates neumorphic decoration for UI elements
  BoxDecoration _buildNeumorphicDecoration({
    bool isInverted = false,
    double depth = 2,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? const Color(0xFFE8F4FD),
      borderRadius: BorderRadius.circular(width * 0.04),
      boxShadow:
          isInverted
              ? [
                // Inverted shadow (pressed effect)
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  offset: Offset(-depth * 2, -depth * 2),
                  blurRadius: depth * 4,
                ),
                BoxShadow(
                  color: const Color(0xFFBEBEBE).withOpacity(0.4),
                  offset: Offset(depth * 2, depth * 2),
                  blurRadius: depth * 4,
                ),
              ]
              : [
                // Normal shadow (raised effect)
                BoxShadow(
                  color: const Color(0xFFBEBEBE).withOpacity(0.4),
                  offset: Offset(depth * 2, depth * 2),
                  blurRadius: depth * 4,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  offset: Offset(-depth * 2, -depth * 2),
                  blurRadius: depth * 4,
                ),
              ],
    );
  }

  // ============ EVENT HANDLERS ============

  /// Handles date selection from calendar
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _showAllTasks = false; // Switch back to date-specific view
    });
  }

  /// Toggles between showing all tasks and date-specific tasks
  void _toggleShowAllTasks() {
    setState(() {
      _showAllTasks = !_showAllTasks;
    });
  }

  /// Handles task completion toggle
  void _toggleTaskComplete(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.toggleComplete(task);
  }

  /// Handles task deletion with animation
  void _deleteTask(Task task, int index) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final animProvider = Provider.of<Animationprovider>(context, listen: false);

    // Start deletion animation first
    animProvider.setTaskDeletionAnimated(index, true);

    // Delete task after animation completes
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        taskProvider.deleteTask(task);
      }
    });
  }

  /// Shows the add task modal bottom sheet
  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddTaskModal(
            taskController: _taskController,
            onAddTask: _addTask,
            onDateTimeSelected: (dateTime) {
              setState(() {
                _selectedDateTime = dateTime;
              });
            },
            selectedDateTime: _selectedDateTime,
          ),
    );
  }

  /// Handles adding a new task
  void _addTask() {
    // Validate input
    if (_taskController.text.trim().isEmpty || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter task title and select date/time'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Create and add new task
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final newTask = Task(
      title: _taskController.text.trim(),
      dueDate: _selectedDateTime,
    );

    taskProvider.addTask(newTask);

    // Clear form and close modal
    _taskController.clear();
    _selectedDateTime = null;
    Navigator.pop(context);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task added successfully!'),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============ REUSABLE WIDGETS ============

/// Calendar day widget with animation support
class CalendarDay extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final int animationIndex;

  const CalendarDay({
    Key? key,
    required this.date,
    required this.selectedDate,
    required this.onDateSelected,
    required this.animationIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final hasTask = taskProvider.getTasksForDate(date).isNotEmpty;
        final isSelected =
            selectedDate.day == date.day &&
            selectedDate.month == date.month &&
            selectedDate.year == date.year;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (animationIndex * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: () => onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  width: width * 0.15,
                  margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF4299E1)
                            : hasTask
                            ? const Color(0xFF68D391)
                            : const Color(0xFFE8F4FD),
                    borderRadius: BorderRadius.circular(width * 0.04),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: const Color(0xFF4299E1).withOpacity(0.5),
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4, -4),
                                blurRadius: 15,
                              ),
                            ]
                            : [
                              BoxShadow(
                                color: const Color(0xFFBEBEBE).withOpacity(0.4),
                                offset: const Offset(4, 4),
                                blurRadius: 8,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                offset: const Offset(-4, -4),
                                blurRadius: 8,
                              ),
                            ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Colors.white
                                  : hasTask
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: width * 0.025,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white.withOpacity(0.9)
                                  : hasTask
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xFF4A5568),
                        ),
                      ),
                      if (hasTask && !isSelected) ...[
                        SizedBox(height: height * 0.005),
                        Container(
                          width: width * 0.015,
                          height: width * 0.015,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Task card widget with Animationprovider integration

class TaskCard extends StatelessWidget {
  final Task task;
  final int index;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.index,
    required this.onToggleComplete,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Consumer<Animationprovider>(
      builder: (context, animProvider, child) {
        // Get animation states from provider
        final isAnimated =
            index < animProvider.taskAnimated.length
                ? animProvider.taskAnimated[index]
                : false;

        final isDeletionAnimated =
            index < animProvider.taskDeletionAnimated.length
                ? animProvider.taskDeletionAnimated[index]
                : false;

        // Trigger entrance animation with staggered delay
        if (!isAnimated && index < animProvider.taskAnimated.length) {
          Future.delayed(Duration(milliseconds: 150 * index), () {
            animProvider.setTaskAnimated(index, true);
          });
        }

        // Get neon color for this task
        final neonColor = animProvider.getNeonColorForTask(index);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          // Slide out animation for deletion
          transform:
              Matrix4.identity()
                ..translate(isDeletionAnimated ? width : 0.0, 0.0, 0.0),
          child: AnimatedOpacity(
            opacity: isAnimated && !isDeletionAnimated ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.008),
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    neonColor.withOpacity(0.1),
                    neonColor.withOpacity(0.05),
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(width * 0.04),
                border: Border.all(
                  color: neonColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  // Neon glow effect
                  BoxShadow(
                    color: neonColor.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                  // Neumorphic shadows
                  BoxShadow(
                    color: const Color(0xFFBEBEBE).withOpacity(0.4),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildAnimatedCheckbox(neonColor),
                  SizedBox(width: width * 0.03),
                  _buildTaskContent(width, height),
                  _buildDeleteButton(width),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds animated checkbox for task completion
  Widget _buildAnimatedCheckbox(Color neonColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(
        begin: task.isCompleted ? 0.0 : 1.0,
        end: task.isCompleted ? 1.0 : 0.0,
      ),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted ? neonColor : Colors.transparent,
              border: Border.all(color: neonColor, width: 2),
              borderRadius: BorderRadius.circular(6),
              boxShadow:
                  task.isCompleted
                      ? [
                        BoxShadow(
                          color: neonColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                      : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onToggleComplete,
                child:
                    task.isCompleted
                        ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                        : null,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds task content (title and due date)
  Widget _buildTaskContent(double width, double height) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task title with completion styling
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w600,
              color:
                  task.isCompleted ? Colors.grey[500] : const Color(0xFF2D3748),
              decoration:
                  task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
            ),
            child: Text(task.title),
          ),
          // Due date if available
          if (task.dueDate != null) ...[
            SizedBox(height: height * 0.005),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: width * 0.035,
                  color: Colors.grey[600],
                ),
                SizedBox(width: width * 0.01),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(task.dueDate!),
                  style: TextStyle(
                    fontSize: width * 0.03,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Builds animated delete button
  Widget _buildDeleteButton(double width) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.02),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(width * 0.02),
                onTap: onDelete,
                child: Padding(
                  padding: EdgeInsets.all(width * 0.02),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red[400],
                    size: width * 0.045,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
