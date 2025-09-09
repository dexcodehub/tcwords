enum LessonType {
  vocabulary,
  grammar,
  listening,
  speaking,
  reading,
  writing,
  pronunciation,
}

enum DifficultyLevel {
  beginner,
  elementary,
  intermediate,
  upperIntermediate,
  advanced,
}

class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DifficultyLevel level;
  final List<Unit> units;
  final int totalLessons;
  final int estimatedDuration; // in minutes
  final List<String> skills;
  final bool isLocked;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.level,
    required this.units,
    required this.totalLessons,
    required this.estimatedDuration,
    required this.skills,
    required this.isLocked,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      level: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => DifficultyLevel.beginner,
      ),
      units: (json['units'] as List)
          .map((unit) => Unit.fromJson(unit))
          .toList(),
      totalLessons: json['totalLessons'],
      estimatedDuration: json['estimatedDuration'],
      skills: List<String>.from(json['skills']),
      isLocked: json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'level': level.name,
      'units': units.map((unit) => unit.toJson()).toList(),
      'totalLessons': totalLessons,
      'estimatedDuration': estimatedDuration,
      'skills': skills,
      'isLocked': isLocked,
    };
  }
}

class Unit {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;
  final bool isCompleted;
  final bool isLocked;

  const Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
    required this.isCompleted,
    required this.isLocked,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
      lessons: (json['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList(),
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'isCompleted': isCompleted,
      'isLocked': isLocked,
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final LessonType type;
  final int order;
  final List<Exercise> exercises;
  final int experiencePoints;
  final bool isCompleted;
  final bool isLocked;
  final String? audioUrl;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    required this.exercises,
    required this.experiencePoints,
    required this.isCompleted,
    required this.isLocked,
    this.audioUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: LessonType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonType.vocabulary,
      ),
      order: json['order'],
      exercises: (json['exercises'] as List)
          .map((exercise) => Exercise.fromJson(exercise))
          .toList(),
      experiencePoints: json['experiencePoints'] ?? 10,
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? false,
      audioUrl: json['audioUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'order': order,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'experiencePoints': experiencePoints,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'audioUrl': audioUrl,
    };
  }
}

enum ExerciseType {
  multipleChoice,
  fillInTheBlank,
  matching,
  listening,
  speaking,
  translation,
  wordOrder,
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? audioUrl;
  final String? imageUrl;
  final int points;

  const Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.audioUrl,
    this.imageUrl,
    required this.points,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      type: ExerciseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExerciseType.multipleChoice,
      ),
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      audioUrl: json['audioUrl'],
      imageUrl: json['imageUrl'],
      points: json['points'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'points': points,
    };
  }
}

class LessonProgress {
  final String lessonId;
  final bool isCompleted;
  final int score;
  final int attempts;
  final DateTime? completedAt;
  final Duration timeSpent;

  const LessonProgress({
    required this.lessonId,
    required this.isCompleted,
    required this.score,
    required this.attempts,
    this.completedAt,
    required this.timeSpent,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'],
      isCompleted: json['isCompleted'] ?? false,
      score: json['score'] ?? 0,
      attempts: json['attempts'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      timeSpent: Duration(seconds: json['timeSpent'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'score': score,
      'attempts': attempts,
      'completedAt': completedAt?.toIso8601String(),
      'timeSpent': timeSpent.inSeconds,
    };
  }
}