import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';
import '../services/course_service.dart';
import '../services/storage_service.dart';

class CourseViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Course> _courses = [];
  Map<String, CourseProgress> _userProgress = {};
  Map<String, LessonProgress> _lessonProgress = {};
  Course? _selectedCourse;
  Lesson? _currentLesson;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  // Getters
  List<Course> get courses => _courses;
  Map<String, CourseProgress> get userProgress => _userProgress;
  Map<String, LessonProgress> get lessonProgress => _lessonProgress;
  Course? get selectedCourse => _selectedCourse;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  // Get courses by difficulty level
  List<Course> getCoursesByLevel(DifficultyLevel level) {
    return _courses.where((course) => course.level == level).toList();
  }

  // Get available (unlocked) courses for user
  Future<List<Course>> getAvailableCourses() async {
    if (_currentUser == null) return [];
    
    final availableCourses = <Course>[];
    for (final course in _courses) {
      final isUnlocked = await CourseService.isCourseUnlocked(_currentUser!.id, course.id);
      if (isUnlocked) {
        availableCourses.add(course);
      }
    }
    return availableCourses;
  }

  // Get course completion percentage
  double getCourseCompletionPercentage(String courseId) {
    final progress = _userProgress[courseId];
    return progress?.completionPercentage ?? 0.0;
  }

  // Get lesson completion status
  bool isLessonCompleted(String lessonId) {
    final progress = _lessonProgress[lessonId];
    return progress?.isCompleted ?? false;
  }

  // Get lesson score
  int getLessonScore(String lessonId) {
    final progress = _lessonProgress[lessonId];
    return progress?.score ?? 0;
  }

  // Initialize the view model
  Future<void> initialize() async {
    _setLoading(true);
    _setError(null);
    
    try {
      // Load current user
      _currentUser = await _storageService.getCurrentUser();
      
      if (_currentUser != null) {
        // Load courses and progress
        await loadCourses();
        await loadUserProgress();
        await loadLessonProgress();
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all courses
  Future<void> loadCourses() async {
    try {
      _courses = await CourseService.getAllCourses();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load courses: $e');
    }
  }

  // Load user progress
  Future<void> loadUserProgress() async {
    if (_currentUser == null) return;
    
    try {
      _userProgress = await CourseService.getUserProgress(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user progress: $e');
    }
  }

  // Load lesson progress
  Future<void> loadLessonProgress() async {
    if (_currentUser == null) return;
    
    try {
      _lessonProgress = await CourseService.getLessonProgress(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load lesson progress: $e');
    }
  }

  // Select a course
  Future<void> selectCourse(String courseId) async {
    try {
      _selectedCourse = await CourseService.getCourseById(courseId);
      
      if (_selectedCourse != null && _currentUser != null) {
        // Update last accessed time
        final currentProgress = _userProgress[courseId] ?? CourseProgress(
          courseId: courseId,
          completionPercentage: 0.0,
          totalXP: 0,
          lastAccessedAt: DateTime.now(),
          isCompleted: false,
        );
        
        final updatedProgress = currentProgress.copyWith(
          lastAccessedAt: DateTime.now(),
        );
        
        await CourseService.updateCourseProgress(
          _currentUser!.id,
          courseId,
          updatedProgress,
        );
        
        _userProgress[courseId] = updatedProgress;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to select course: $e');
    }
  }

  // Get next lesson for user in selected course
  Future<void> loadNextLesson() async {
    if (_selectedCourse == null || _currentUser == null) return;
    
    try {
      _currentLesson = await CourseService.getNextLesson(
        _currentUser!.id,
        _selectedCourse!.id,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load next lesson: $e');
    }
  }

  // Start a lesson
  Future<void> startLesson(String lessonId) async {
    if (_selectedCourse == null || _currentUser == null) return;
    
    try {
      // Find the lesson in the selected course
      Lesson? lesson;
      for (final unit in _selectedCourse!.units) {
        try {
          lesson = unit.lessons.firstWhere((l) => l.id == lessonId);
          break;
        } catch (e) {
          continue;
        }
      }
      
      if (lesson != null) {
        _currentLesson = lesson;
        
        // Initialize lesson progress if not exists
        if (!_lessonProgress.containsKey(lessonId)) {
          final progress = LessonProgress(
            lessonId: lessonId,
            isCompleted: false,
            score: 0,
            attempts: 0,
            timeSpent: Duration.zero,
          );
          
          await CourseService.updateLessonProgress(
            _currentUser!.id,
            lessonId,
            progress,
          );
          
          _lessonProgress[lessonId] = progress;
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to start lesson: $e');
    }
  }

  // Complete a lesson with score
  Future<void> completeLesson(String lessonId, int score, Duration timeSpent) async {
    if (_currentUser == null) return;
    
    try {
      final currentProgress = _lessonProgress[lessonId];
      if (currentProgress == null) return;
      
      final updatedProgress = LessonProgress(
        lessonId: lessonId,
        isCompleted: true,
        score: score,
        attempts: currentProgress.attempts + 1,
        completedAt: DateTime.now(),
        timeSpent: currentProgress.timeSpent + timeSpent,
      );
      
      await CourseService.updateLessonProgress(
        _currentUser!.id,
        lessonId,
        updatedProgress,
      );
      
      _lessonProgress[lessonId] = updatedProgress;
      
      // Update course progress
      if (_selectedCourse != null) {
        await _updateCourseProgress(_selectedCourse!.id);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete lesson: $e');
    }
  }

  // Update course progress based on lesson completions
  Future<void> _updateCourseProgress(String courseId) async {
    if (_currentUser == null) return;
    
    try {
      final completionPercentage = await CourseService.getCourseCompletionPercentage(
        _currentUser!.id,
        courseId,
      );
      
      final currentProgress = _userProgress[courseId] ?? CourseProgress(
        courseId: courseId,
        completionPercentage: 0.0,
        totalXP: 0,
        lastAccessedAt: DateTime.now(),
        isCompleted: false,
      );
      
      // Calculate total XP from completed lessons
      int totalXP = 0;
      final course = await CourseService.getCourseById(courseId);
      if (course != null) {
        for (final unit in course.units) {
          for (final lesson in unit.lessons) {
            final progress = _lessonProgress[lesson.id];
            if (progress?.isCompleted ?? false) {
              totalXP += lesson.experiencePoints;
            }
          }
        }
      }
      
      final updatedProgress = currentProgress.copyWith(
        completionPercentage: completionPercentage,
        totalXP: totalXP,
        lastAccessedAt: DateTime.now(),
        isCompleted: completionPercentage >= 1.0,
        completedAt: completionPercentage >= 1.0 ? DateTime.now() : null,
      );
      
      await CourseService.updateCourseProgress(
        _currentUser!.id,
        courseId,
        updatedProgress,
      );
      
      _userProgress[courseId] = updatedProgress;
    } catch (e) {
      _setError('Failed to update course progress: $e');
    }
  }

  // Get user's total XP across all courses
  int getTotalXP() {
    return _userProgress.values.fold(0, (sum, progress) => sum + progress.totalXP);
  }

  // Get user's completed courses count
  int getCompletedCoursesCount() {
    return _userProgress.values.where((progress) => progress.isCompleted).length;
  }

  // Get user's current streak (this would typically come from a separate service)
  Future<int> getCurrentStreak() async {
    try {
      return await _storageService.getCurrentStreak();
    } catch (e) {
      return 0;
    }
  }

  // Reset course progress (for testing or user request)
  Future<void> resetCourseProgress(String courseId) async {
    if (_currentUser == null) return;
    
    try {
      // Reset course progress
      final resetProgress = CourseProgress(
        courseId: courseId,
        completionPercentage: 0.0,
        totalXP: 0,
        lastAccessedAt: DateTime.now(),
        isCompleted: false,
      );
      
      await CourseService.updateCourseProgress(
        _currentUser!.id,
        courseId,
        resetProgress,
      );
      
      _userProgress[courseId] = resetProgress;
      
      // Reset lesson progress for this course
      final course = await CourseService.getCourseById(courseId);
      if (course != null) {
        for (final unit in course.units) {
          for (final lesson in unit.lessons) {
            final resetLessonProgress = LessonProgress(
              lessonId: lesson.id,
              isCompleted: false,
              score: 0,
              attempts: 0,
              timeSpent: Duration.zero,
            );
            
            await CourseService.updateLessonProgress(
              _currentUser!.id,
              lesson.id,
              resetLessonProgress,
            );
            
            _lessonProgress[lesson.id] = resetLessonProgress;
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset course progress: $e');
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}