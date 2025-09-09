import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tcword/src/models/word.dart';
import 'storage_service.dart';

class WordService {
  static const String _dataPath = 'assets/data/words.json';
  static const String _bookmarksKey = 'bookmarked_words';
  static const String _learningStatusKey = 'word_learning_status';
  
  final StorageService _storageService = StorageService();
  
  // 单例模式
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  // 获取所有单词（包含学习状态和收藏信息）
  Future<List<Word>> getAllWords() async {
    try {
      final String response = await rootBundle.loadString(_dataPath);
      final List<dynamic> data = json.decode(response);
      final words = data.map((e) => Word.fromJson(e)).toList();
      
      // 加载学习状态和收藏信息
      return await _enrichWordsWithUserData(words);
    } catch (e) {
      // 如果加载失败，返回空列表
      return [];
    }
  }
  
  // 为单词添加用户数据（学习状态、收藏等）
  Future<List<Word>> _enrichWordsWithUserData(List<Word> words) async {
    final bookmarks = await getBookmarkedWordIds();
    final learningStatuses = await _getLearningStatuses();
    
    return words.map((word) {
      final status = learningStatuses[word.id] ?? LearningStatus.notStarted;
      final isBookmarked = bookmarks.contains(word.id);
      
      return word.copyWith(
        learningStatus: status,
        isBookmarked: isBookmarked,
      );
    }).toList();
  }

  // 根据分类获取单词
  Future<List<Word>> getWordsByCategory(String category) async {
    final List<Word> allWords = await getAllWords();
    return allWords.where((word) => word.category == category).toList();
  }

  // 获取所有分类
  Future<List<String>> getCategories() async {
    final List<Word> allWords = await getAllWords();
    final Set<String> categories = allWords.map((word) => word.category).toSet();
    return categories.toList();
  }
  
  // === 收藏功能 ===
  
  // 收藏单词
  Future<bool> bookmarkWord(String wordId) async {
    try {
      final bookmarks = await getBookmarkedWordIds();
      if (!bookmarks.contains(wordId)) {
        bookmarks.add(wordId);
        await _saveBookmarks(bookmarks);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 取消收藏单词
  Future<bool> unbookmarkWord(String wordId) async {
    try {
      final bookmarks = await getBookmarkedWordIds();
      bookmarks.remove(wordId);
      await _saveBookmarks(bookmarks);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 切换收藏状态
  Future<bool> toggleBookmark(String wordId) async {
    final bookmarks = await getBookmarkedWordIds();
    if (bookmarks.contains(wordId)) {
      return await unbookmarkWord(wordId);
    } else {
      return await bookmarkWord(wordId);
    }
  }
  
  // 获取收藏的单词ID列表
  Future<List<String>> getBookmarkedWordIds() async {
    try {
      final prefs = await _storageService.getAppSettings();
      final bookmarksJson = prefs[_bookmarksKey] as String?;
      if (bookmarksJson != null) {
        final List<dynamic> bookmarksList = json.decode(bookmarksJson);
        return bookmarksList.cast<String>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // 获取收藏的单词列表
  Future<List<Word>> getBookmarkedWords() async {
    final bookmarkedIds = await getBookmarkedWordIds();
    final allWords = await getAllWords();
    return allWords.where((word) => bookmarkedIds.contains(word.id)).toList();
  }
  
  // 保存收藏列表
  Future<void> _saveBookmarks(List<String> bookmarks) async {
    final settings = await _storageService.getAppSettings();
    settings[_bookmarksKey] = json.encode(bookmarks);
    await _storageService.saveAppSettings(settings);
  }
  
  // === 搜索功能 ===
  
  // 模糊搜索单词
  Future<List<Word>> searchWords(String query, {
    List<WordDifficulty>? difficulties,
    List<String>? categories,
    List<LearningStatus>? learningStatuses,
    bool? isBookmarked,
  }) async {
    if (query.trim().isEmpty) {
      return await getAllWords();
    }
    
    final allWords = await getAllWords();
    final lowercaseQuery = query.toLowerCase().trim();
    
    // 筛选结果
    List<Word> filteredWords = allWords.where((word) {
      // 文本匹配
      final textMatch = word.text.toLowerCase().contains(lowercaseQuery) ||
          (word.meaning?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          (word.example?.toLowerCase().contains(lowercaseQuery) ?? false);
      
      if (!textMatch) return false;
      
      // 难度筛选
      if (difficulties != null && difficulties.isNotEmpty) {
        if (!difficulties.contains(word.difficulty)) return false;
      }
      
      // 分类筛选
      if (categories != null && categories.isNotEmpty) {
        if (!categories.contains(word.category)) return false;
      }
      
      // 学习状态筛选
      if (learningStatuses != null && learningStatuses.isNotEmpty) {
        if (!learningStatuses.contains(word.learningStatus)) return false;
      }
      
      // 收藏状态筛选
      if (isBookmarked != null) {
        if (word.isBookmarked != isBookmarked) return false;
      }
      
      return true;
    }).toList();
    
    // 按相关性排序
    filteredWords.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, lowercaseQuery);
      final scoreB = _calculateRelevanceScore(b, lowercaseQuery);
      return scoreB.compareTo(scoreA); // 降序排列
    });
    
    return filteredWords;
  }
  
  // 计算相关性分数
  int _calculateRelevanceScore(Word word, String query) {
    int score = 0;
    final text = word.text.toLowerCase();
    final meaning = word.meaning?.toLowerCase() ?? '';
    final example = word.example?.toLowerCase() ?? '';
    
    // 完全匹配分数最高
    if (text == query) score += 100;
    if (meaning == query) score += 80;
    
    // 前缀匹配
    if (text.startsWith(query)) score += 50;
    if (meaning.startsWith(query)) score += 30;
    
    // 包含匹配
    if (text.contains(query)) score += 20;
    if (meaning.contains(query)) score += 15;
    if (example.contains(query)) score += 10;
    
    return score;
  }
  
  // 获取搜索建议
  Future<List<String>> getSearchSuggestions(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return [];
    
    final allWords = await getAllWords();
    final lowercaseQuery = query.toLowerCase().trim();
    
    final suggestions = <String>{};
    
    for (final word in allWords) {
      // 单词文本建议
      if (word.text.toLowerCase().startsWith(lowercaseQuery)) {
        suggestions.add(word.text);
      }
      
      // 含义建议
      if (word.meaning != null &&
          word.meaning!.toLowerCase().contains(lowercaseQuery)) {
        suggestions.add(word.meaning!);
      }
      
      if (suggestions.length >= limit) break;
    }
    
    return suggestions.take(limit).toList();
  }
  
  // === 学习状态管理 ===
  
  // 更新学习状态
  Future<bool> updateLearningStatus(String wordId, LearningStatus status) async {
    try {
      final statuses = await _getLearningStatuses();
      statuses[wordId] = status;
      await _saveLearningStatuses(statuses);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // 获取学习状态
  Future<Map<String, LearningStatus>> _getLearningStatuses() async {
    try {
      final prefs = await _storageService.getAppSettings();
      final statusesJson = prefs[_learningStatusKey] as String?;
      if (statusesJson != null) {
        final Map<String, dynamic> statusesMap = json.decode(statusesJson);
        return statusesMap.map((key, value) => 
            MapEntry(key, _parseLearningStatus(value)));
      }
      return {};
    } catch (e) {
      return {};
    }
  }
  
  // 保存学习状态
  Future<void> _saveLearningStatuses(Map<String, LearningStatus> statuses) async {
    final settings = await _storageService.getAppSettings();
    final statusesMap = statuses.map((key, value) => MapEntry(key, value.name));
    settings[_learningStatusKey] = json.encode(statusesMap);
    await _storageService.saveAppSettings(settings);
  }
  
  // 解析学习状态
  LearningStatus _parseLearningStatus(dynamic status) {
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
  
  // 根据学习状态获取单词
  Future<List<Word>> getWordsByLearningStatus(LearningStatus status) async {
    final allWords = await getAllWords();
    return allWords.where((word) => word.learningStatus == status).toList();
  }
  
  // 获取学习统计
  Future<Map<String, int>> getLearningStatistics() async {
    final allWords = await getAllWords();
    final stats = <String, int>{
      'total': allWords.length,
      'notStarted': 0,
      'learning': 0,
      'reviewing': 0,
      'mastered': 0,
      'bookmarked': 0,
    };
    
    for (final word in allWords) {
      switch (word.learningStatus) {
        case LearningStatus.notStarted:
          stats['notStarted'] = stats['notStarted']! + 1;
          break;
        case LearningStatus.learning:
          stats['learning'] = stats['learning']! + 1;
          break;
        case LearningStatus.reviewing:
          stats['reviewing'] = stats['reviewing']! + 1;
          break;
        case LearningStatus.mastered:
          stats['mastered'] = stats['mastered']! + 1;
          break;
      }
      
      if (word.isBookmarked) {
        stats['bookmarked'] = stats['bookmarked']! + 1;
      }
    }
    
    return stats;
  }
}