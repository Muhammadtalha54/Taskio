// Add Task Modal Widget
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskModal extends StatefulWidget {
  final TextEditingController taskController;
  final VoidCallback onAddTask;
  final Function(DateTime?) onDateTimeSelected;
  final DateTime? selectedDateTime;

  const AddTaskModal({
    Key? key,
    required this.taskController,
    required this.onAddTask,
    required this.onDateTimeSelected,
    this.selectedDateTime,
  }) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(width * 0.06),
            topRight: Radius.circular(width * 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: width * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: height * 0.03),

            // Title
            Text(
              'Add New Task',
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.03),

            // Task input field
            TextField(
              controller: widget.taskController,
              decoration: InputDecoration(
                hintText: 'Enter task title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                  borderSide: const BorderSide(
                    color: Color(0xFF4299E1),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.03),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
              ),
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: height * 0.025),

            // Date and Time Selection
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.02,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(width * 0.03),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: const Color(0xFF4299E1),
                      size: width * 0.05,
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Text(
                        widget.selectedDateTime != null
                            ? DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(widget.selectedDateTime!)
                            : 'Select date and time',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color:
                              widget.selectedDateTime != null
                                  ? const Color(0xFF2D3748)
                                  : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: width * 0.04,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: height * 0.04),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03),
                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(width * 0.03),
                        onTap: () {
                          widget.taskController.clear();
                          widget.onDateTimeSelected(null);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                          ),
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),

                // Add Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF63B3ED),
                          Color(0xFF4299E1),
                          Color(0xFF3182CE),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4299E1).withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(width * 0.03),
                        onTap: widget.onAddTask,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                          ),
                          child: Text(
                            'Add Task',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    // First select date
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4299E1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      // Then select time
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4299E1),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF2D3748),
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        widget.onDateTimeSelected(combinedDateTime);
      }
    }
  }
}
