import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_model.dart';
import '../viewmodels/courses_viewmodel.dart';
import '../widgets/course_card.dart';
// import '../widgets/custom_app_bar.dart';
// import '../widgets/loading_widget.dart';
// import '../widgets/error_widget.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/difficulty_badge.dart';
import 'course_detail_view.dart';

class CoursesView extends StatefulWidget {
  const CoursesView({super.key});

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CoursesViewModel _coursesViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: DifficultyLevel.values.length, vsync: this);
    _coursesViewModel = Provider.of<CoursesViewModel>(context, listen: false);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _coursesViewModel.loadCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程中心'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<CoursesViewModel>(builder: (context, viewModel, child) {
            final progress = viewModel.getUserProgress();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${progress['completedCourses']}/${progress['totalCourses']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Consumer<CoursesViewModel>(builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('加载课程中...'),
              ],
            ),
          );
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.error!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _initializeData(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // User Stats Section
            _buildUserStatsSection(viewModel),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: viewModel.searchCourses,
                decoration: InputDecoration(
                  hintText: '搜索课程...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            
            // Tab Bar
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: DifficultyLevel.values.map((level) {
                  return Tab(
                    text: _getLevelDisplayName(level),
                  );
                }).toList(),
              ),
            ),
            
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: DifficultyLevel.values.map((level) {
                  return _buildCourseList(viewModel, level);
                }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUserStatsSection(CoursesViewModel viewModel) {
    final progress = viewModel.getUserProgress();
    final courseCounts = viewModel.getCoursesCountByLevel();
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.school,
              label: '已完成课程',
              value: '${progress['completedCourses']}',
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.library_books,
              label: '总课程数',
              value: '${progress['totalCourses']}',
              color: Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.trending_up,
              label: '完成率',
              value: '${progress['progressPercentage']}%',
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCourseList(CoursesViewModel viewModel, DifficultyLevel level) {
    final courses = viewModel.courses.where((course) => course.level == level).toList();
    
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无${_getLevelDisplayName(level)}课程',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CourseCard(
              course: course,
              completionPercentage: _calculateProgress(course),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/course/${course.id}',
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _getLevelDisplayName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return '初级';
      case DifficultyLevel.elementary:
        return '基础';
      case DifficultyLevel.intermediate:
        return '中级';
      case DifficultyLevel.upperIntermediate:
        return '中高级';
      case DifficultyLevel.advanced:
        return '高级';
    }
  }

  double _calculateProgress(Course course) {
    if (course.units.isEmpty) return 0.0;
    
    final completedUnits = course.units.where((unit) => unit.isCompleted).length;
    return completedUnits / course.units.length;
  }
}