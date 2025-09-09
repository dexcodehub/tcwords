import 'package:flutter/material.dart';
import '../word.dart';

/// 测验类型枚举
enum QuizType {
  englishToChinese,   // 英译中
  chineseToEnglish,   // 中译英
  listeningChoice,    // 听音选义
  spelling,           // 拼写测试
}

/// 测验题目
class QuizQuestion {
  final String id;
  final QuizType type;
  final Word word;
  final List<String> options;
  final int correctAnswerIndex;
  final String? audioPath;

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.word,
    required this.options,
    required this.correctAnswerIndex,
    this.audioPath,
  });

  /// 从JSON创建QuizQuestion对象
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      type: _parseQuizType(json['type']),
      word: Word.fromJson(json['word']),
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      audioPath: json['audioPath'],
    );
  }

  static QuizType _parseQuizType(String type) {
    switch (type.toLowerCase()) {
      case 'englishToChinese':
        return QuizType.englishToChinese;
      case 'chineseToEnglish':
        return QuizType.chineseToEnglish;
      case 'listeningChoice':
        return QuizType.listeningChoice;
      case 'spelling':
        return QuizType.spelling;
      default:
        return QuizType.englishToChinese;
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'word': word.toJson(),
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'audioPath': audioPath,
    };
  }

  /// 获取测验类型显示名称
  String getTypeName() {
    switch (type) {
      case QuizType.englishToChinese:
        return '英译中';
      case QuizType.chineseToEnglish:
        return '中译英';
      case QuizType.listeningChoice:
        return '听音选义';
      case QuizType.spelling:
        return '拼写测试';
    }
  }

  /// 获取题目显示文本
  String getQuestionText() {
    switch (type) {
      case QuizType.englishToChinese:
        return word.text;
      case QuizType.chineseToEnglish:
        return word.meaning ?? word.text;
      case QuizType.listeningChoice:
        return '🔊 点击播放';
      case QuizType.spelling:
        return word.meaning ?? word.text;
    }
  }

  /// 获取正确答案
  String getCorrectAnswer() {
    return options[correctAnswerIndex];
  }

  /// 检查答案是否正确
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }

  /// 复制方法
  QuizQuestion copyWith({
    String? id,
    QuizType? type,
    Word? word,
    List<String>? options,
    int? correctAnswerIndex,
    String? audioPath,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      type: type ?? this.type,
      word: word ?? this.word,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      audioPath: audioPath ?? this.audioPath,
    );
  }
}

/// 用户答案
class QuizAnswer {
  final String questionId;
  final int selectedIndex;
  final bool isCorrect;
  final DateTime answeredAt;
  final Duration timeSpent;

  const QuizAnswer({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeSpent,
  });

  /// 从JSON创建QuizAnswer对象
  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      questionId: json['questionId'],
      selectedIndex: json['selectedIndex'],
      isCorrect: json['isCorrect'],
      answeredAt: DateTime.parse(json['answeredAt']),
      timeSpent: Duration(milliseconds: json['timeSpentMs']),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedIndex': selectedIndex,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.toIso8601String(),
      'timeSpentMs': timeSpent.inMilliseconds,
    };
  }
}

/// 测验会话
class QuizSession {
  final String id;
  final String title;
  final QuizType type;
  final List<QuizQuestion> questions;
  final List<QuizAnswer> answers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int timeLimit; // 秒数，0表示无限制
  final double passingScore; // 及格分数百分比

  const QuizSession({
    required this.id,
    required this.title,
    required this.type,
    required this.questions,
    this.answers = const [],
    required this.startedAt,
    this.completedAt,
    this.timeLimit = 0,
    this.passingScore = 0.6,
  });

  /// 从JSON创建QuizSession对象
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'],
      title: json['title'],
      type: QuizQuestion._parseQuizType(json['type']),
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      answers: (json['answers'] as List? ?? [])
          .map((a) => QuizAnswer.fromJson(a))
          .toList(),
      startedAt: DateTime.parse(json['startedAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      timeLimit: json['timeLimit'] ?? 0,
      passingScore: json['passingScore']?.toDouble() ?? 0.6,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'timeLimit': timeLimit,
      'passingScore': passingScore,
    };
  }

  /// 获取当前题目索引
  int get currentQuestionIndex => answers.length;

  /// 获取当前题目
  QuizQuestion? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// 检查是否完成
  bool get isCompleted => currentQuestionIndex >= questions.length;

  /// 获取进度百分比
  double get progress => questions.isEmpty ? 0.0 : currentQuestionIndex / questions.length;

  /// 获取正确答案数量
  int get correctAnswersCount => answers.where((a) => a.isCorrect).length;

  /// 获取正确率
  double get accuracy => answers.isEmpty ? 0.0 : correctAnswersCount / answers.length;

  /// 获取分数（百分制）
  int get score => (accuracy * 100).round();

  /// 检查是否及格
  bool get isPassed => accuracy >= passingScore;

  /// 获取总用时
  Duration get totalDuration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    }
    return DateTime.now().difference(startedAt);
  }

  /// 获取平均每题用时
  Duration get averageTimePerQuestion {
    if (answers.isEmpty) return Duration.zero;
    final totalMs = answers.fold<int>(0, (sum, answer) => sum + answer.timeSpent.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ answers.length);
  }

  /// 添加答案
  QuizSession addAnswer(QuizAnswer answer) {
    return copyWith(
      answers: [...answers, answer],
      completedAt: currentQuestionIndex + 1 >= questions.length 
          ? DateTime.now() 
          : completedAt,
    );
  }

  /// 复制方法
  QuizSession copyWith({
    String? id,
    String? title,
    QuizType? type,
    List<QuizQuestion>? questions,
    List<QuizAnswer>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
    int? timeLimit,
    double? passingScore,
  }) {
    return QuizSession(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeLimit: timeLimit ?? this.timeLimit,
      passingScore: passingScore ?? this.passingScore,
    );
  }
}

/// 测验结果
class QuizResult {
  final String sessionId;
  final String title;
  final QuizType type;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final int score;
  final bool isPassed;
  final Duration totalTime;
  final Duration averageTimePerQuestion;
  final DateTime completedAt;
  final List<QuizAnswer> answers;
  final List<String> incorrectQuestionIds;

  const QuizResult({
    required this.sessionId,
    required this.title,
    required this.type,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.score,
    required this.isPassed,
    required this.totalTime,
    required this.averageTimePerQuestion,
    required this.completedAt,
    required this.answers,
    required this.incorrectQuestionIds,
  });

  /// 从QuizSession创建QuizResult
  factory QuizResult.fromSession(QuizSession session) {
    final incorrectIds = session.answers
        .where((answer) => !answer.isCorrect)
        .map((answer) => answer.questionId)
        .toList();

    return QuizResult(
      sessionId: session.id,
      title: session.title,
      type: session.type,
      totalQuestions: session.questions.length,
      correctAnswers: session.correctAnswersCount,
      accuracy: session.accuracy,
      score: session.score,
      isPassed: session.isPassed,
      totalTime: session.totalDuration,
      averageTimePerQuestion: session.averageTimePerQuestion,
      completedAt: session.completedAt ?? DateTime.now(),
      answers: session.answers,
      incorrectQuestionIds: incorrectIds,
    );
  }

  /// 从JSON创建QuizResult对象
  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      sessionId: json['sessionId'],
      title: json['title'],
      type: QuizQuestion._parseQuizType(json['type']),
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      accuracy: json['accuracy'].toDouble(),
      score: json['score'],
      isPassed: json['isPassed'],
      totalTime: Duration(milliseconds: json['totalTimeMs']),
      averageTimePerQuestion: Duration(milliseconds: json['avgTimePerQuestionMs']),
      completedAt: DateTime.parse(json['completedAt']),
      answers: (json['answers'] as List)
          .map((a) => QuizAnswer.fromJson(a))
          .toList(),
      incorrectQuestionIds: List<String>.from(json['incorrectQuestionIds']),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'type': type.name,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'score': score,
      'isPassed': isPassed,
      'totalTimeMs': totalTime.inMilliseconds,
      'avgTimePerQuestionMs': averageTimePerQuestion.inMilliseconds,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'incorrectQuestionIds': incorrectQuestionIds,
    };
  }

  /// 获取分数颜色
  Color getScoreColor() {
    if (score >= 90) return const Color(0xFF4CAF50); // 绿色 - 优秀
    if (score >= 80) return const Color(0xFF2196F3); // 蓝色 - 良好
    if (score >= 70) return const Color(0xFFFF9800); // 橙色 - 中等
    if (score >= 60) return const Color(0xFFFFC107); // 黄色 - 及格
    return const Color(0xFFE53935); // 红色 - 不及格
  }

  /// 获取分数等级
  String getScoreGrade() {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '中等';
    if (score >= 60) return '及格';
    return '不及格';
  }
}