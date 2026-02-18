import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/assignment_provider.dart';
import '../../data/models/assignment_model.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  @override
  Widget build(BuildContext context) {
    final assignmentProvider = context.watch<AssignmentProvider>();
    final assignments = assignmentProvider.assignments;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              assignmentProvider.setFilter(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'All',
                child: Row(
                  children: [
                    if (assignmentProvider.filter == 'All')
                      const Icon(Icons.check, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text('All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Pending',
                child: Row(
                  children: [
                    if (assignmentProvider.filter == 'Pending')
                      const Icon(Icons.check, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text('Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'Completed',
                child: Row(
                  children: [
                    if (assignmentProvider.filter == 'Completed')
                      const Icon(Icons.check, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Text('Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: AppTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No assignments yet',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first assignment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return _AssignmentListCard(
                  assignment: assignment,
                  onToggle: () {
                    assignmentProvider.toggleAssignmentStatus(assignment);
                  },
                  onEdit: () => _showAssignmentDialog(context, assignment: assignment),
                  onDelete: () => _confirmDelete(context, assignment),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAssignmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAssignmentDialog(BuildContext context, {AssignmentModel? assignment}) {
    final isEditing = assignment != null;
    final titleController = TextEditingController(text: assignment?.title ?? '');
    final subjectController = TextEditingController(text: assignment?.subject ?? '');
    final descriptionController = TextEditingController(text: assignment?.description ?? '');
    DateTime dueDate = assignment?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    TimeOfDay dueTime = assignment != null
        ? TimeOfDay.fromDateTime(assignment.dueDate)
        : const TimeOfDay(hour: 23, minute: 59);
    String priority = assignment?.priority ?? 'Medium';
    int? customReminder = assignment?.customReminderMinutes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEditing ? 'Edit Assignment' : 'Add Assignment',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: const Icon(Icons.book),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: dueDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setModalState(() {
                                  dueDate = date;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due Date',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(AppDateUtils.formatDate(dueDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: dueTime,
                              );
                              if (time != null) {
                                setModalState(() {
                                  dueTime = time;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due Time',
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(dueTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: priority,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: AppConstants.priorityLevels.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.getPriorityColor(p),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(child: Text(p, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          priority = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int?>(
                      value: customReminder,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Custom Reminder',
                        prefixIcon: const Icon(Icons.notifications),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Default', overflow: TextOverflow.ellipsis)),
                        const DropdownMenuItem(value: 30, child: Text('30 min before', overflow: TextOverflow.ellipsis)),
                        const DropdownMenuItem(value: 120, child: Text('2 hours before', overflow: TextOverflow.ellipsis)),
                        const DropdownMenuItem(value: 360, child: Text('6 hours before', overflow: TextOverflow.ellipsis)),
                        const DropdownMenuItem(value: 720, child: Text('12 hours before', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          customReminder = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a title')),
                          );
                          return;
                        }
                        if (subjectController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a subject')),
                          );
                          return;
                        }

                        // Gather all data synchronously
                        final provider = context.read<AssignmentProvider>();
                        final title = titleController.text;
                        final subject = subjectController.text;
                        final description = descriptionController.text.isEmpty ? null : descriptionController.text;

                        final fullDueDate = DateTime(
                          dueDate.year,
                          dueDate.month,
                          dueDate.day,
                          dueTime.hour,
                          dueTime.minute,
                        );

                        // Close dialog FIRST
                        Navigator.of(context).pop();

                        // Then perform async operations
                        if (isEditing) {
                          provider.updateAssignment(
                            assignment!.copyWith(
                              title: title,
                              subject: subject,
                              description: description,
                              dueDate: fullDueDate,
                              priority: priority,
                              customReminderMinutes: customReminder,
                            ),
                          );
                        } else {
                          provider.addAssignment(
                            title: title,
                            subject: subject,
                            dueDate: fullDueDate,
                            priority: priority,
                            description: description,
                            customReminderMinutes: customReminder,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Update' : 'Add Assignment',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: Text('Are you sure you want to delete "${assignment.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<AssignmentProvider>().deleteAssignment(assignment.id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _AssignmentListCard extends StatefulWidget {
  final AssignmentModel assignment;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AssignmentListCard({
    required this.assignment,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AssignmentListCard> createState() => _AssignmentListCardState();
}

class _AssignmentListCardState extends State<_AssignmentListCard> {
  bool _isToggling = false;

  void _handleToggle() {
    if (_isToggling) return; // Prevent multiple taps

    setState(() {
      _isToggling = true;
    });

    widget.onToggle();

    // Reset after a short delay to allow the operation to complete
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isToggling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = widget.assignment.isOverdue;
    final isCompleted = widget.assignment.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue && !isCompleted
            ? Border.all(color: AppTheme.errorColor.withOpacity(0.5), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: _handleToggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successColor
                  : AppTheme.getPriorityColor(widget.assignment.priority).withOpacity(0.1),
              shape: BoxShape.circle,
              border: isCompleted
                  ? null
                  : Border.all(
                      color: AppTheme.getPriorityColor(widget.assignment.priority),
                      width: 2,
                    ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        ),
        title: Text(
          widget.assignment.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isCompleted ? AppTheme.textLight : AppTheme.textPrimary,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.book_outlined, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  widget.assignment.subject,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: isOverdue && !isCompleted
                      ? AppTheme.errorColor
                      : AppTheme.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  isOverdue && !isCompleted
                      ? 'Overdue'
                      : AppDateUtils.getRelativeDate(widget.assignment.dueDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isOverdue && !isCompleted
                        ? AppTheme.errorColor
                        : AppTheme.textSecondary,
                    fontWeight: isOverdue && !isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.getPriorityColor(widget.assignment.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.assignment.priority,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getPriorityColor(widget.assignment.priority),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              widget.onEdit();
            } else {
              widget.onDelete();
            }
          },
        ),
      ),
    );
  }
}

