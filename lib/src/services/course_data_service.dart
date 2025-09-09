import '../models/course_model.dart';

class CourseDataService {
  static List<Course> getSampleCourses() {
    return [
      Course(
        id: 'course_1',
        title: '英语入门基础',
        description: '适合零基础学习者的英语入门课程，从字母发音开始，逐步建立英语基础。',
        imageUrl: 'assets/images/course_beginner.png',
        level: DifficultyLevel.beginner,
        totalLessons: 20,
        estimatedDuration: 600,
        skills: ['字母发音', '基础词汇', '简单对话'],
        isLocked: false,
        units: [
          Unit(
            id: 'unit_1_1',
            title: '字母与发音',
            description: '学习26个英文字母及其发音规则',
            order: 1,
            isCompleted: false,
            isLocked: false,
            lessons: [
              Lesson(
                id: 'lesson_1_1_1',
                title: '字母A-G的发音',
                description: '学习字母A到G的正确发音方法',
                type: LessonType.pronunciation,
                order: 1,
                experiencePoints: 10,
                isCompleted: false,
                isLocked: false,
                exercises: [],
              ),
            ],
          ),
        ],
      ),
      Course(
        id: 'course_2',
        title: '日常英语对话',
        description: '学习日常生活中常用的英语对话，提高口语交流能力。',
        imageUrl: 'assets/images/course_elementary.png',
        level: DifficultyLevel.elementary,
        totalLessons: 25,
        estimatedDuration: 750,
        skills: ['日常对话', '实用词汇', '语法基础'],
        isLocked: false,
        units: [
          Unit(
            id: 'unit_2_1',
            title: '问候与介绍',
            description: '学习如何用英语进行问候和自我介绍',
            order: 1,
            isCompleted: false,
            isLocked: false,
            lessons: [
              Lesson(
                id: 'lesson_2_1_1',
                title: '基本问候语',
                description: '学习Hello, Hi, Good morning等基本问候语',
                type: LessonType.speaking,
                order: 1,
                experiencePoints: 12,
                isCompleted: false,
                isLocked: false,
                exercises: [],
              ),
            ],
          ),
        ],
      ),
      Course(
        id: 'course_3',
        title: '商务英语基础',
        description: '掌握商务场合中的基本英语表达，适合职场人士学习。',
        imageUrl: 'assets/images/course_intermediate.png',
        level: DifficultyLevel.intermediate,
        totalLessons: 30,
        estimatedDuration: 900,
        skills: ['商务词汇', '邮件写作', '会议英语'],
        isLocked: false,
        units: [
          Unit(
            id: 'unit_3_1',
            title: '商务邮件',
            description: '学习如何撰写专业的商务邮件',
            order: 1,
            isCompleted: false,
            isLocked: false,
            lessons: [
              Lesson(
                id: 'lesson_3_1_1',
                title: '邮件开头与结尾',
                description: '学习商务邮件的标准开头和结尾表达',
                type: LessonType.writing,
                order: 1,
                experiencePoints: 18,
                isCompleted: false,
                isLocked: false,
                exercises: [],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  static Course? getCourseById(String courseId) {
    final courses = getSampleCourses();
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  static List<Course> getCoursesByLevel(DifficultyLevel level) {
    return getSampleCourses()
        .where((course) => course.level == level)
        .toList();
  }

  static List<Course> getRecommendedCourses(DifficultyLevel userLevel) {
    final courses = getSampleCourses();
    
    final recommendedLevels = <DifficultyLevel>[];
    recommendedLevels.add(userLevel);
    
    switch (userLevel) {
      case DifficultyLevel.beginner:
        recommendedLevels.add(DifficultyLevel.elementary);
        break;
      case DifficultyLevel.elementary:
        recommendedLevels.add(DifficultyLevel.intermediate);
        break;
      case DifficultyLevel.intermediate:
        recommendedLevels.add(DifficultyLevel.upperIntermediate);
        break;
      case DifficultyLevel.upperIntermediate:
        recommendedLevels.add(DifficultyLevel.advanced);
        break;
      case DifficultyLevel.advanced:
        return courses;
    }
    
    return courses
        .where((course) => recommendedLevels.contains(course.level))
        .toList();
  }
}