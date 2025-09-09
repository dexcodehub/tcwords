import 'package:flutter/material.dart';
import '../../models/word.dart';
import '../../models/course_model.dart';
import '../../services/word_service.dart';
import '../custom_text_field.dart';
import '../custom_button.dart';
import '../difficulty_badge.dart';
import '../learning/word_card.dart';

class WordSearchBar extends StatefulWidget {
  final Function(List<Word>)? onSearchResults;
  final Function(String)? onQueryChanged;
  final bool showFilters;
  final bool showResults;
  final double? maxHeight;
  final String? initialQuery;

  const WordSearchBar({
    super.key,
    this.onSearchResults,
    this.onQueryChanged,
    this.showFilters = true,
    this.showResults = true,
    this.maxHeight,
    this.initialQuery,
  });

  @override
  State<WordSearchBar> createState() => _WordSearchBarState();
}

class _WordSearchBarState extends State<WordSearchBar> {
  late TextEditingController _searchController;
  final WordService _wordService = WordService();
  
  List<Word> _searchResults = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  
  // 筛选器状态
  Set<WordDifficulty> _selectedDifficulties = {};
  Set<String> _selectedCategories = {};
  Set<LearningStatus> _selectedLearningStatuses = {};
  bool? _bookmarkFilter; // null = 全部, true = 已收藏, false = 未收藏
  
  // 可用的筛选选项
  List<String> _availableCategories = [];
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _loadAvailableCategories();
    
    // 如果有初始查询，立即搜索
    if (widget.initialQuery?.isNotEmpty == true) {
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableCategories() async {
    try {
      final categories = await _wordService.getCategories();
      setState(() {
        _availableCategories = categories;
      });
    } catch (e) {
      debugPrint('Load categories error: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });

    try {
      final results = await _wordService.searchWords(
        query,
        difficulties: _selectedDifficulties.isEmpty ? null : _selectedDifficulties.toList(),
        categories: _selectedCategories.isEmpty ? null : _selectedCategories.toList(),
        learningStatuses: _selectedLearningStatuses.isEmpty ? null : _selectedLearningStatuses.toList(),
        isBookmarked: _bookmarkFilter,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

      widget.onSearchResults?.call(results);
      widget.onQueryChanged?.call(query);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      debugPrint('Search error: $e');
    }
  }

  Future<void> _loadSuggestions(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final suggestions = await _wordService.getSearchSuggestions(query);
      setState(() {
        _searchSuggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    } catch (e) {
      debugPrint('Load suggestions error: $e');
    }
  }

  void _onSearchChanged(String query) {
    // 延迟搜索以避免频繁调用
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == query) {
        if (query.trim().isEmpty) {
          setState(() {
            _searchResults = [];
            _searchSuggestions = [];
            _showSuggestions = false;
          });
        } else {
          _loadSuggestions(query);
        }
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _performSearch(query);
    }
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _searchSuggestions = [];
      _showSuggestions = false;
    });
    widget.onSearchResults?.call([]);
    widget.onQueryChanged?.call('');
  }

  void _toggleDifficultyFilter(WordDifficulty difficulty) {
    setState(() {
      if (_selectedDifficulties.contains(difficulty)) {
        _selectedDifficulties.remove(difficulty);
      } else {
        _selectedDifficulties.add(difficulty);
      }
    });
    
    // 如果有查询，重新搜索
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _toggleCategoryFilter(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _toggleLearningStatusFilter(LearningStatus status) {
    setState(() {
      if (_selectedLearningStatuses.contains(status)) {
        _selectedLearningStatuses.remove(status);
      } else {
        _selectedLearningStatuses.add(status);
      }
    });
    
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _toggleBookmarkFilter() {
    setState(() {
      if (_bookmarkFilter == null) {
        _bookmarkFilter = true; // 只显示已收藏
      } else if (_bookmarkFilter == true) {
        _bookmarkFilter = false; // 只显示未收藏
      } else {
        _bookmarkFilter = null; // 显示全部
      }
    });
    
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDifficulties.clear();
      _selectedCategories.clear();
      _selectedLearningStatuses.clear();
      _bookmarkFilter = null;
    });
    
    if (_searchController.text.trim().isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeightValue = widget.maxHeight ?? MediaQuery.of(context).size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeightValue),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索输入框
          _buildSearchField(),
          
          // 搜索建议
          if (_showSuggestions) _buildSuggestionsList(),
          
          // 筛选器
          if (widget.showFilters) _buildFilters(),
          
          // 搜索结果
          if (widget.showResults) _buildSearchResults(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SearchTextField(
        controller: _searchController,
        hintText: '搜索单词、含义或例句...',
        onChanged: _onSearchChanged,
        onSubmitted: _onSearchSubmitted,
        onClear: _clearSearch,
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.search, size: 18),
            title: Text(suggestion),
            onTap: () => _selectSuggestion(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 筛选器标题和清除按钮
          Row(
            children: [
              Text(
                '筛选器',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('清除全部'),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 难度筛选
          _buildDifficultyFilters(),
          
          const SizedBox(height: 12),
          
          // 其他筛选器
          _buildOtherFilters(),
          
          // 分类筛选（如果有可用分类）
          if (_availableCategories.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCategoryFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildDifficultyFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '难度',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: WordDifficulty.values.map((difficulty) {
            final isSelected = _selectedDifficulties.contains(difficulty);
            final level = _wordDifficultyToLevel(difficulty);
            
            return GestureDetector(
              onTap: () => _toggleDifficultyFilter(difficulty),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ) : null,
                ),
                child: DifficultyBadge(
                  level: level,
                  compact: true,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOtherFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 收藏筛选
        CustomButton(
          text: _bookmarkFilter == null
              ? '收藏状态'
              : _bookmarkFilter == true
                  ? '已收藏'
                  : '未收藏',
          icon: _bookmarkFilter == true
              ? Icons.bookmark
              : _bookmarkFilter == false
                  ? Icons.bookmark_border
                  : Icons.bookmark_outline,
          isOutlined: _bookmarkFilter == null,
          onPressed: _toggleBookmarkFilter,
          height: 36,
        ),
        
        // 学习状态筛选
        ...LearningStatus.values.map((status) {
          final isSelected = _selectedLearningStatuses.contains(status);
          return CustomButton(
            text: _getLearningStatusText(status),
            icon: _getLearningStatusIcon(status),
            isOutlined: !isSelected,
            backgroundColor: isSelected ? _getLearningStatusColor(status) : null,
            onPressed: () => _toggleLearningStatusFilter(status),
            height: 36,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    if (_availableCategories.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _availableCategories.take(6).map((category) {
            final isSelected = _selectedCategories.contains(category);
            return CustomButton(
              text: category.toUpperCase(),
              isOutlined: !isSelected,
              onPressed: () => _toggleCategoryFilter(category),
              height: 32,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.trim().isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '未找到相关单词',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '尝试调整搜索词或筛选条件',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final word = _searchResults[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WordCard(
              word: word,
              height: 200,
              onFlip: () {
                // 可以添加搜索统计
              },
            ),
          );
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedDifficulties.isNotEmpty ||
        _selectedCategories.isNotEmpty ||
        _selectedLearningStatuses.isNotEmpty ||
        _bookmarkFilter != null;
  }

  // 工具方法
  DifficultyLevel _wordDifficultyToLevel(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.beginner:
        return DifficultyLevel.beginner;
      case WordDifficulty.elementary:
        return DifficultyLevel.elementary;
      case WordDifficulty.intermediate:
        return DifficultyLevel.intermediate;
      case WordDifficulty.advanced:
        return DifficultyLevel.advanced;
    }
  }

  String _getLearningStatusText(LearningStatus status) {
    switch (status) {
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

  IconData _getLearningStatusIcon(LearningStatus status) {
    switch (status) {
      case LearningStatus.notStarted:
        return Icons.play_circle_outline;
      case LearningStatus.learning:
        return Icons.school_outlined;
      case LearningStatus.reviewing:
        return Icons.refresh_outlined;
      case LearningStatus.mastered:
        return Icons.check_circle_outline;
    }
  }

  Color _getLearningStatusColor(LearningStatus status) {
    switch (status) {
      case LearningStatus.notStarted:
        return Colors.grey;
      case LearningStatus.learning:
        return Colors.blue;
      case LearningStatus.reviewing:
        return Colors.orange;
      case LearningStatus.mastered:
        return Colors.green;
    }
  }
}