import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/course_data_service.dart';

class CoursesViewModel extends ChangeNotifier {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = false;
  String? _error;
  DifficultyLevel? _selectedLevel;
  String _searchQuery = '';

  List<Course> get courses => _filteredCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DifficultyLevel? get selectedLevel => _selectedLevel;
  String get searchQuery => _searchQuery;

  CoursesViewModel() {
    loadCourses();
  }

  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      _courses = CourseDataService.getSampleCourses();
      _applyFilters();
      _isLoading = false;
    } catch (e) {
      _error = '加载课程失败: $e';
      _isLoading = false;
    }
    
    notifyListeners();
  }

  void filterByLevel(DifficultyLevel? level) {
    _selectedLevel = level;
    _applyFilters();
    notifyListeners();
  }

  void searchCourses(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCourses = _courses.where((course) {
      // 级别过滤
      if (_selectedLevel != null && course.level != _selectedLevel) {
        return false;
      }
      
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return course.title.toLowerCase().contains(query) ||
               course.description.toLowerCase().contains(query) ||
               course.skills.any((skill) => skill.toLowerCase().contains(query));
      }
      
      return true;
    }).toList();
  }

  List<Course> getRecommendedCourses(DifficultyLevel userLevel) {
    return CourseDataService.getRecommendedCourses(userLevel);
  }

  Course? getCourseById(String courseId) {
    return CourseDataService.getCourseById(courseId);
  }

  void clearFilters() {
    _selectedLevel = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadCourses();
  }

  // 获取课程统计信息
  Map<DifficultyLevel, int> getCoursesCountByLevel() {
    final Map<DifficultyLevel, int> counts = {};
    
    for (final level in DifficultyLevel.values) {
      counts[level] = _courses.where((course) => course.level == level).length;
    }
    
    return counts;
  }

  // 获取用户进度统计
  Map<String, dynamic> getUserProgress() {
    final totalCourses = _courses.length;
    final completedCourses = _courses.where((course) => 
        course.units.every((unit) => unit.isCompleted)).length;
    
    return {
      'totalCourses': totalCourses,
      'completedCourses': completedCourses,
      'progressPercentage': totalCourses > 0 ? (completedCourses / totalCourses * 100).round() : 0,
    };
  }
}