import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../viewmodels/course_viewmodel.dart';
// import '../widgets/custom_app_bar.dart';
// import '../widgets/loading_widget.dart';
// import 'lesson_view.dart';

class CourseDetailView extends StatefulWidget {
  final Course course;

  const CourseDetailView({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailView> createState() => _CourseDetailViewState();
}

class _CourseDetailViewState extends State<CourseDetailView> {
  late CourseViewModel _courseViewModel;

  @override
  void initState() {
    super.initState();
    _courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        backgroundColor: _getCourseGradientColors(widget.course.level)[0],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CourseViewModel>(builder: (context, viewModel, child) {
        final completionPercentage = viewModel.getCourseCompletionPercentage(widget.course.id);
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              _buildCourseHeader(completionPercentage),
              
              // Course Stats
              _buildCourseStats(),
              
              // Skills Section
              if (widget.course.skills.isNotEmpty)
                _buildSkillsSection(),
              
              // Units Section
              _buildUnitsSection(viewModel),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCourseHeader(double completionPercentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCourseGradientColors(widget.course.level),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCourseIcon(widget.course.level),
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLevelDisplayName(widget.course.level),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.course.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          
          // Progress Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '学习进度',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${(completionPercentage * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.play_lesson,
              title: '课时数量',
              value: '${widget.course.totalLessons}',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time,
              title: '预计时长',
              value: '${widget.course.estimatedDuration ~/ 60}h ${widget.course.estimatedDuration % 60}m',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.category,
              title: '单元数量',
              value: '${widget.course.units.length}',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '学习技能',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.course.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUnitsSection(CourseViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '课程单元',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.course.units.length,
            itemBuilder: (context, index) {
              final unit = widget.course.units[index];
              return _buildUnitCard(unit, viewModel);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUnitCard(Unit unit, CourseViewModel viewModel) {
    final completedLessons = unit.lessons.where((lesson) {
      return viewModel.isLessonCompleted(lesson.id);
    }).length;
    
    final unitProgress = unit.lessons.isNotEmpty 
        ? completedLessons / unit.lessons.length 
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: unitProgress == 1.0 
                ? Colors.green.withOpacity(0.2)
                : Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            unitProgress == 1.0 ? Icons.check_circle : Icons.play_circle_outline,
            color: unitProgress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          unit.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              unit.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$completedLessons/${unit.lessons.length} 课时完成',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: unitProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        unitProgress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: unit.lessons.map((lesson) {
          return _buildLessonTile(lesson, viewModel);
        }).toList(),
      ),
    );
  }

  Widget _buildLessonTile(Lesson lesson, CourseViewModel viewModel) {
    final isCompleted = viewModel.isLessonCompleted(lesson.id);
    final score = viewModel.getLessonScore(lesson.id);
    
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          isCompleted ? Icons.check : _getLessonTypeIcon(lesson.type),
          color: isCompleted ? Colors.green : Colors.grey[600],
          size: 18,
        ),
      ),
      title: Text(
        lesson.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isCompleted ? Colors.green[700] : null,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            _getLessonTypeDisplayName(lesson.type),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(width: 8),
            Text(
              '得分: $score',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${lesson.experiencePoints} XP',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
      onTap: () => _navigateToLesson(lesson),
    );
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.vocabulary:
        return Icons.spellcheck;
      case LessonType.grammar:
        return Icons.auto_fix_high;
      case LessonType.listening:
        return Icons.hearing;
      case LessonType.speaking:
        return Icons.record_voice_over;
      case LessonType.reading:
        return Icons.menu_book;
      case LessonType.writing:
        return Icons.edit;
      case LessonType.pronunciation:
        return Icons.volume_up;
    }
  }

  String _getLessonTypeDisplayName(LessonType type) {
    switch (type) {
      case LessonType.vocabulary:
        return '词汇';
      case LessonType.grammar:
        return '语法';
      case LessonType.listening:
        return '听力';
      case LessonType.speaking:
        return '口语';
      case LessonType.reading:
        return '阅读';
      case LessonType.writing:
        return '写作';
      case LessonType.pronunciation:
        return '发音';
    }
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

  void _navigateToLesson(Lesson lesson) async {
    // Start the lesson in view model
    await _courseViewModel.startLesson(lesson.id);
    
    if (mounted) {
      // TODO: Navigate to lesson view when LessonView is implemented
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('开始学习: ${lesson.title}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}