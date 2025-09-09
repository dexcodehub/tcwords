import 'package:flutter/material.dart';
import '../models/course_model.dart';
import 'progress_indicator.dart';
import 'difficulty_badge.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final double completionPercentage;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.completionPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Course Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: _getCourseGradientColors(course.level),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      _getCourseIcon(course.level),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Course Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (course.isLocked)
                              Icon(
                                Icons.lock,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        DifficultyBadge(
                          level: course.level,
                          compact: true,
                          fontSize: 12,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Course Stats
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.play_lesson,
                    label: '${course.totalLessons} 课时',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    icon: Icons.access_time,
                    label: '${course.estimatedDuration ~/ 60}h ${course.estimatedDuration % 60}m',
                    color: Colors.orange,
                  ),
                  const Spacer(),
                  if (completionPercentage > 0)
                    Text(
                      '${(completionPercentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress Bar
              CustomProgressIndicator(
                progress: completionPercentage,
                height: 6,
                progressColor: _getProgressColor(completionPercentage),
                backgroundColor: Colors.grey[300],
              ),
              
              const SizedBox(height: 12),
              
              // Skills Tags
              if (course.skills.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: course.skills.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getCourseGradientColors(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return [Colors.green[400]!, Colors.green[600]!];
      case DifficultyLevel.elementary:
        return [Colors.blue[400]!, Colors.blue[600]!];
      case DifficultyLevel.intermediate:
        return [Colors.orange[400]!, Colors.orange[600]!];
      case DifficultyLevel.upperIntermediate:
        return [Colors.purple[400]!, Colors.purple[600]!];
      case DifficultyLevel.advanced:
        return [Colors.red[400]!, Colors.red[600]!];
    }
  }

  IconData _getCourseIcon(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Icons.school;
      case DifficultyLevel.elementary:
        return Icons.menu_book;
      case DifficultyLevel.intermediate:
        return Icons.psychology;
      case DifficultyLevel.upperIntermediate:
        return Icons.emoji_objects;
      case DifficultyLevel.advanced:
        return Icons.military_tech;
    }
  }

  String _getLevelDisplayName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return '入门级';
      case DifficultyLevel.elementary:
        return '初级';
      case DifficultyLevel.intermediate:
        return '中级';
      case DifficultyLevel.upperIntermediate:
        return '中高级';
      case DifficultyLevel.advanced:
        return '高级';
    }
  }

  Color _getLevelColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Colors.green[600]!;
      case DifficultyLevel.elementary:
        return Colors.blue[600]!;
      case DifficultyLevel.intermediate:
        return Colors.orange[600]!;
      case DifficultyLevel.upperIntermediate:
        return Colors.purple[600]!;
      case DifficultyLevel.advanced:
        return Colors.red[600]!;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red[400]!;
    } else if (progress < 0.7) {
      return Colors.orange[400]!;
    } else {
      return Colors.green[400]!;
    }
  }
}