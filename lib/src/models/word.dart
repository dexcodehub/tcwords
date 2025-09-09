import 'package:flutter/material.dart';

enum WordDifficulty {
  beginner,
  elementary,
  intermediate,
  advanced,
}

enum LearningStatus {
  notStarted,
  learning,
  reviewing,
  mastered,
}

class Word {
  final String id;
  final String text;
  final String category;
  final String imagePath;
  final String audioPath;
  final String? meaning;
  final String? example;
  final WordDifficulty difficulty;
  final LearningStatus learningStatus;
  final bool isBookmarked;
  final DateTime? lastReviewedAt;
  final int reviewCount;

  const Word({
    required this.id,
    required this.text,
    required this.category,
    required this.imagePath,
    required this.audioPath,
    this.meaning,
    this.example,
    this.difficulty = WordDifficulty.beginner,
    this.learningStatus = LearningStatus.notStarted,
    this.isBookmarked = false,
    this.lastReviewedAt,
    this.reviewCount = 0,
  });

  // 从JSON创建Word对象（向后兼容）
  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      text: json['text'],
      category: json['category'],
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      meaning: json['meaning'],
      example: json['example'],
      difficulty: _parseDifficulty(json['difficulty']),
      learningStatus: _parseLearningStatus(json['learningStatus']),
      isBookmarked: json['isBookmarked'] ?? false,
      lastReviewedAt: json['lastReviewedAt'] != null 
          ? DateTime.parse(json['lastReviewedAt']) 
          : null,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  static WordDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty == null) return WordDifficulty.beginner;
    switch (difficulty.toString().toLowerCase()) {
      case 'elementary':
        return WordDifficulty.elementary;
      case 'intermediate':
        return WordDifficulty.intermediate;
      case 'advanced':
        return WordDifficulty.advanced;
      default:
        return WordDifficulty.beginner;
    }
  }

  static LearningStatus _parseLearningStatus(dynamic status) {
    if (status == null) return LearningStatus.notStarted;
    switch (status.toString().toLowerCase()) {
      case 'learning':
        return LearningStatus.learning;
      case 'reviewing':
        return LearningStatus.reviewing;
      case 'mastered':
        return LearningStatus.mastered;
      default:
        return LearningStatus.notStarted;
    }
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'meaning': meaning,
      'example': example,
      'difficulty': difficulty.name,
      'learningStatus': learningStatus.name,
      'isBookmarked': isBookmarked,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'reviewCount': reviewCount,
    };
  }

  // 复制方法，用于更新状态
  Word copyWith({
    String? id,
    String? text,
    String? category,
    String? imagePath,
    String? audioPath,
    String? meaning,
    String? example,
    WordDifficulty? difficulty,
    LearningStatus? learningStatus,
    bool? isBookmarked,
    DateTime? lastReviewedAt,
    int? reviewCount,
  }) {
    return Word(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      difficulty: difficulty ?? this.difficulty,
      learningStatus: learningStatus ?? this.learningStatus,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  // 获取难度颜色
  Color getDifficultyColor() {
    switch (difficulty) {
      case WordDifficulty.beginner:
        return const Color(0xFF4CAF50); // 绿色
      case WordDifficulty.elementary:
        return const Color(0xFF2196F3); // 蓝色
      case WordDifficulty.intermediate:
        return const Color(0xFFFF9800); // 橙色
      case WordDifficulty.advanced:
        return const Color(0xFFE53935); // 红色
    }
  }

  // 获取难度显示名称
  String getDifficultyName() {
    switch (difficulty) {
      case WordDifficulty.beginner:
        return '入门';
      case WordDifficulty.elementary:
        return '初级';
      case WordDifficulty.intermediate:
        return '中级';
      case WordDifficulty.advanced:
        return '高级';
    }
  }

  // 获取学习状态颜色
  Color getStatusColor() {
    switch (learningStatus) {
      case LearningStatus.notStarted:
        return const Color(0xFF9E9E9E); // 灰色
      case LearningStatus.learning:
        return const Color(0xFF2196F3); // 蓝色
      case LearningStatus.reviewing:
        return const Color(0xFFFF9800); // 橙色
      case LearningStatus.mastered:
        return const Color(0xFF4CAF50); // 绿色
    }
  }

  // 获取学习状态显示名称
  String getStatusName() {
    switch (learningStatus) {
      case LearningStatus.notStarted:
        return '未开始';
      case LearningStatus.learning:
        return '学习中';
      case LearningStatus.reviewing:
        return '复习中';
      case LearningStatus.mastered:
        return '已掌握';
    }
  }
}