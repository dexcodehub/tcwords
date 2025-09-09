import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

class CourseService {
  static const String _coursesKey = 'courses';
  static const String _userProgressKey = 'user_progress';
  static const String _lessonProgressKey = 'lesson_progress';

  // Get all available courses
  static Future<List<Course>> getAllCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString(_coursesKey);
      if (coursesJson != null) {
        final coursesList = json.decode(coursesJson) as List;
        return coursesList.map((course) => Course.fromJson(course)).toList();
      }
      return _getDefaultCourses();
    } catch (e) {
      print('Error loading courses: $e');
      return _getDefaultCourses();
    }
  }

  // Get courses by difficulty level
  static Future<List<Course>> getCoursesByLevel(DifficultyLevel level) async {
    final allCourses = await getAllCourses();
    return allCourses.where((course) => course.level == level).toList();
  }

  // Get course by ID
  static Future<Course?> getCourseById(String courseId) async {
    final allCourses = await getAllCourses();
    try {
      return allCourses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Get user's course progress
  static Future<Map<String, CourseProgress>> getUserProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('${_userProgressKey}_$userId');
      if (progressJson != null) {
        final progressMap = json.decode(progressJson) as Map<String, dynamic>;
        return progressMap.map(
          (key, value) => MapEntry(key, CourseProgress.fromJson(value)),
        );
      }
      return {};
    } catch (e) {
      print('Error loading user progress: $e');
      return {};
    }
  }

  // Update user's course progress
  static Future<void> updateCourseProgress(
    String userId,
    String courseId,
    CourseProgress progress,
  ) async {
    try {
      final currentProgress = await getUserProgress(userId);
      currentProgress[courseId] = progress;
      
      final progressData = currentProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_userProgressKey}_$userId', json.encode(progressData));
    } catch (e) {
      print('Error updating course progress: $e');
    }
  }

  // Get lesson progress for a user
  static Future<Map<String, LessonProgress>> getLessonProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('${_lessonProgressKey}_$userId');
      if (progressJson != null) {
        final progressMap = json.decode(progressJson) as Map<String, dynamic>;
        return progressMap.map(
          (key, value) => MapEntry(key, LessonProgress.fromJson(value)),
        );
      }
      return {};
    } catch (e) {
      print('Error loading lesson progress: $e');
      return {};
    }
  }

  // Update lesson progress
  static Future<void> updateLessonProgress(
    String userId,
    String lessonId,
    LessonProgress progress,
  ) async {
    try {
      final currentProgress = await getLessonProgress(userId);
      currentProgress[lessonId] = progress;
      
      final progressData = currentProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_lessonProgressKey}_$userId', json.encode(progressData));
    } catch (e) {
      print('Error updating lesson progress: $e');
    }
  }

  // Check if a course is unlocked for the user
  static Future<bool> isCourseUnlocked(String userId, String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null || !course.isLocked) return true;
    
    final userProgress = await getUserProgress(userId);
    // Check if user has completed prerequisite courses
    // This is a simplified check - in a real app, you'd have more complex logic
    return userProgress.length >= course.level.index;
  }

  // Check if a lesson is unlocked for the user
  static Future<bool> isLessonUnlocked(String userId, String courseId, String lessonId) async {
    final course = await getCourseById(courseId);
    if (course == null) return false;
    
    // Find the lesson in the course
    Lesson? targetLesson;
    for (final unit in course.units) {
      try {
        targetLesson = unit.lessons.firstWhere((lesson) => lesson.id == lessonId);
        break;
      } catch (e) {
        continue;
      }
    }
    
    if (targetLesson == null || !targetLesson.isLocked) return true;
    
    final lessonProgress = await getLessonProgress(userId);
    
    // Check if previous lessons in the same unit are completed
    for (final unit in course.units) {
      final lessonIndex = unit.lessons.indexWhere((lesson) => lesson.id == lessonId);
      if (lessonIndex > 0) {
        final previousLesson = unit.lessons[lessonIndex - 1];
        final progress = lessonProgress[previousLesson.id];
        return progress?.isCompleted ?? false;
      }
    }
    
    return true;
  }

  // Calculate course completion percentage
  static Future<double> getCourseCompletionPercentage(String userId, String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null) return 0.0;
    
    final lessonProgress = await getLessonProgress(userId);
    int completedLessons = 0;
    int totalLessons = 0;
    
    for (final unit in course.units) {
      for (final lesson in unit.lessons) {
        totalLessons++;
        final progress = lessonProgress[lesson.id];
        if (progress?.isCompleted ?? false) {
          completedLessons++;
        }
      }
    }
    
    return totalLessons > 0 ? completedLessons / totalLessons : 0.0;
  }

  // Get recommended next lesson for user
  static Future<Lesson?> getNextLesson(String userId, String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null) return null;
    
    final lessonProgress = await getLessonProgress(userId);
    
    for (final unit in course.units) {
      for (final lesson in unit.lessons) {
        final progress = lessonProgress[lesson.id];
        if (progress == null || !progress.isCompleted) {
          final isUnlocked = await isLessonUnlocked(userId, courseId, lesson.id);
          if (isUnlocked) {
            return lesson;
          }
        }
      }
    }
    
    return null; // All lessons completed
  }

  // Get default courses for initial setup
  static List<Course> _getDefaultCourses() {
    return [
      Course(
        id: 'beginner_vocabulary',
        title: '基础词汇',
        description: '学习日常生活中最常用的英语单词',
        imageUrl: 'assets/images/beginner_vocabulary.png',
        level: DifficultyLevel.beginner,
        units: _getBeginnerVocabularyUnits(),
        totalLessons: 20,
        estimatedDuration: 300, // 5 hours
        skills: ['基础词汇', '发音', '拼写'],
        isLocked: false,
      ),
      Course(
        id: 'elementary_grammar',
        title: '初级语法',
        description: '掌握英语基础语法规则',
        imageUrl: 'assets/images/elementary_grammar.png',
        level: DifficultyLevel.elementary,
        units: _getElementaryGrammarUnits(),
        totalLessons: 25,
        estimatedDuration: 400, // 6.7 hours
        skills: ['基础语法', '句型结构', '时态'],
        isLocked: true,
      ),
      Course(
        id: 'intermediate_conversation',
        title: '中级对话',
        description: '提升日常对话和交流能力',
        imageUrl: 'assets/images/intermediate_conversation.png',
        level: DifficultyLevel.intermediate,
        units: _getIntermediateConversationUnits(),
        totalLessons: 30,
        estimatedDuration: 500, // 8.3 hours
        skills: ['对话技巧', '听力理解', '口语表达'],
        isLocked: true,
      ),
    ];
  }

  static List<Unit> _getBeginnerVocabularyUnits() {
    return [
      Unit(
        id: 'unit_1',
        title: '问候与介绍',
        description: '学习基本的问候语和自我介绍',
        order: 1,
        lessons: [
          Lesson(
            id: 'lesson_1_1',
            title: '基本问候',
            description: '学习Hello, Hi, Good morning等问候语',
            type: LessonType.vocabulary,
            order: 1,
            exercises: [
              Exercise(
                id: 'ex_1_1_1',
                type: ExerciseType.multipleChoice,
                question: '"Hello"的中文意思是？',
                options: ['再见', '你好', '谢谢', '对不起'],
                correctAnswer: '你好',
                explanation: 'Hello是最常用的问候语，意思是"你好"',
                points: 10,
              ),
            ],
            experiencePoints: 50,
            isCompleted: false,
            isLocked: false,
          ),
        ],
        isCompleted: false,
        isLocked: false,
      ),
    ];
  }

  static List<Unit> _getElementaryGrammarUnits() {
    return [
      Unit(
        id: 'grammar_unit_1',
        title: '现在时态',
        description: '学习一般现在时的用法',
        order: 1,
        lessons: [
          Lesson(
            id: 'grammar_lesson_1_1',
            title: '一般现在时',
            description: '学习一般现在时的基本结构和用法',
            type: LessonType.grammar,
            order: 1,
            exercises: [
              Exercise(
                id: 'grammar_ex_1_1_1',
                type: ExerciseType.fillInTheBlank,
                question: 'I ___ a student.',
                options: ['am', 'is', 'are', 'be'],
                correctAnswer: 'am',
                explanation: '主语是I时，be动词用am',
                points: 15,
              ),
            ],
            experiencePoints: 75,
            isCompleted: false,
            isLocked: false,
          ),
        ],
        isCompleted: false,
        isLocked: false,
      ),
    ];
  }

  static List<Unit> _getIntermediateConversationUnits() {
    return [
      Unit(
        id: 'conversation_unit_1',
        title: '日常对话',
        description: '练习日常生活中的对话场景',
        order: 1,
        lessons: [
          Lesson(
            id: 'conversation_lesson_1_1',
            title: '购物对话',
            description: '学习在商店购物时的常用对话',
            type: LessonType.speaking,
            order: 1,
            exercises: [
              Exercise(
                id: 'conversation_ex_1_1_1',
                type: ExerciseType.listening,
                question: '听对话，选择正确答案：顾客想买什么？',
                options: ['苹果', '香蕉', '橙子', '葡萄'],
                correctAnswer: '苹果',
                explanation: '对话中顾客说"I want to buy some apples"',
                audioUrl: 'assets/audio/shopping_conversation.mp3',
                points: 20,
              ),
            ],
            experiencePoints: 100,
            isCompleted: false,
            isLocked: false,
            audioUrl: 'assets/audio/shopping_lesson.mp3',
          ),
        ],
        isCompleted: false,
        isLocked: false,
      ),
    ];
  }
}

// Course progress model
class CourseProgress {
  final String courseId;
  final double completionPercentage;
  final int totalXP;
  final DateTime lastAccessedAt;
  final bool isCompleted;
  final DateTime? completedAt;

  const CourseProgress({
    required this.courseId,
    required this.completionPercentage,
    required this.totalXP,
    required this.lastAccessedAt,
    required this.isCompleted,
    this.completedAt,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'],
      completionPercentage: json['completionPercentage']?.toDouble() ?? 0.0,
      totalXP: json['totalXP'] ?? 0,
      lastAccessedAt: DateTime.parse(json['lastAccessedAt']),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'completionPercentage': completionPercentage,
      'totalXP': totalXP,
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  CourseProgress copyWith({
    String? courseId,
    double? completionPercentage,
    int? totalXP,
    DateTime? lastAccessedAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      totalXP: totalXP ?? this.totalXP,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}