import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/assignment_model.dart';

class AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onToggle;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = assignment.isCompleted;
    final isOverdue = assignment.isOverdue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue && !isCompleted
            ? Border.all(color: AppTheme.errorColor.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successColor
                    : AppTheme.getPriorityColor(assignment.priority).withOpacity(0.1),
                shape: BoxShape.circle,
                border: isCompleted
                    ? null
                    : Border.all(
                        color: AppTheme.getPriorityColor(assignment.priority),
                        width: 2,
                      ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? AppTheme.textLight : AppTheme.textPrimary,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      assignment.subject,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.textLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOverdue && !isCompleted
                          ? 'Overdue'
                          : AppDateUtils.getRelativeDate(assignment.dueDate),
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
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.getPriorityColor(assignment.priority).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              assignment.priority,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.getPriorityColor(assignment.priority),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

