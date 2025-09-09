import 'package:flutter/material.dart';
import '../../models/word.dart';
import '../../services/word_service.dart';
import '../custom_button.dart';
import '../custom_text_field.dart';
import '../learning/word_card.dart';

/// 单词收藏组件
/// 
/// 功能特性：
/// - 多种视图模式（列表、网格）
/// - 搜索和筛选功能
/// - 批量操作（取消收藏、复习）
/// - 统计信息显示
/// - 空状态处理
class WordBookmark extends StatefulWidget {
  final VoidCallback? onWordTap;
  final VoidCallback? onStartReview;
  final Function(List<Word>)? onBatchOperation;

  const WordBookmark({
    super.key,
    this.onWordTap,
    this.onStartReview,
    this.onBatchOperation,
  });

  @override
  State<WordBookmark> createState() => _WordBookmarkState();
}

class _WordBookmarkState extends State<WordBookmark> {
  final WordService _wordService = WordService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Word> _bookmarkedWords = [];
  List<Word> _filteredWords = [];
  Map<String, int> _statistics = {};
  
  // UI状态
  bool _isLoading = false;
  bool _isGridView = false;
  bool _isSelectionMode = false;
  Set<String> _selectedWordIds = {};
  
  // 筛选状态
  String _selectedCategory = '';
  LearningStatus? _selectedStatus;
  WordDifficulty? _selectedDifficulty;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBookmarkedWords();
    _loadStatistics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarkedWords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final words = await _wordService.getBookmarkedWords();
      setState(() {
        _bookmarkedWords = words;
        _filteredWords = words;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载收藏失败');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _wordService.getLearningStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      debugPrint('Failed to load statistics: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredWords = _bookmarkedWords.where((word) {
        // 搜索过滤
        bool matchesSearch = _searchQuery.isEmpty ||
            word.text.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (word.meaning?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // 分类过滤
        bool matchesCategory = _selectedCategory.isEmpty ||
            word.category == _selectedCategory;

        // 学习状态过滤
        bool matchesStatus = _selectedStatus == null ||
            word.learningStatus == _selectedStatus;

        // 难度过滤
        bool matchesDifficulty = _selectedDifficulty == null ||
            word.difficulty == _selectedDifficulty;

        return matchesSearch && matchesCategory && matchesStatus && matchesDifficulty;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedWordIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedWordIds.clear();
    });
  }

  void _toggleWordSelection(String wordId) {
    setState(() {
      if (_selectedWordIds.contains(wordId)) {
        _selectedWordIds.remove(wordId);
      } else {
        _selectedWordIds.add(wordId);
      }
    });
  }

  void _selectAllWords() {
    setState(() {
      _selectedWordIds = _filteredWords.map((word) => word.id).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedWordIds.clear();
    });
  }

  Future<void> _batchUnbookmark() async {
    if (_selectedWordIds.isEmpty) return;

    try {
      for (final wordId in _selectedWordIds) {
        await _wordService.unbookmarkWord(wordId);
      }
      
      _showSuccessSnackBar('已取消收藏 ${_selectedWordIds.length} 个单词');
      _exitSelectionMode();
      _loadBookmarkedWords();
      _loadStatistics();
    } catch (e) {
      _showErrorSnackBar('批量取消收藏失败');
    }
  }

  void _startReview() {
    final selectedWords = _filteredWords
        .where((word) => _selectedWordIds.contains(word.id))
        .toList();
    
    if (selectedWords.isNotEmpty) {
      widget.onBatchOperation?.call(selectedWords);
    }
    widget.onStartReview?.call();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          if (_statistics.isNotEmpty) _buildStatisticsCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWords.isEmpty
                    ? _buildEmptyState()
                    : _buildWordsList(),
          ),
        ],
      ),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isSelectionMode 
          ? '已选择 ${_selectedWordIds.length} 项' 
          : '我的收藏'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: _isSelectionMode
          ? [
              if (_selectedWordIds.length < _filteredWords.length)
                TextButton(
                  onPressed: _selectAllWords,
                  child: const Text('全选'),
                ),
              TextButton(
                onPressed: _exitSelectionMode,
                child: const Text('取消'),
              ),
            ]
          : [
              IconButton(
                icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
                onPressed: _toggleViewMode,
                tooltip: _isGridView ? '列表视图' : '网格视图',
              ),
              IconButton(
                icon: const Icon(Icons.checklist),
                onPressed: _enterSelectionMode,
                tooltip: '批量操作',
              ),
            ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomTextField(
        controller: _searchController,
        hintText: '搜索收藏的单词...',
        prefixIcon: Icons.search,
        onChanged: _onSearchChanged,
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFilterBar() {
    if (_bookmarkedWords.isEmpty) return const SizedBox.shrink();

    // 获取所有分类
    final categories = _bookmarkedWords
        .map((word) => word.category)
        .toSet()
        .toList()
        ..sort();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 全部筛选
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('全部'),
              selected: _selectedCategory.isEmpty &&
                  _selectedStatus == null &&
                  _selectedDifficulty == null,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = '';
                  _selectedStatus = null;
                  _selectedDifficulty = null;
                });
                _applyFilters();
              },
            ),
          ),

          // 分类筛选
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.toUpperCase()),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : '';
                    });
                    _applyFilters();
                  },
                ),
              )),

          // 学习状态筛选
          ...LearningStatus.values.map((status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getStatusName(status)),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                    _applyFilters();
                  },
                  backgroundColor: _getStatusColor(status).withOpacity(0.1),
                  selectedColor: _getStatusColor(status).withOpacity(0.3),
                ),
              )),

          // 难度筛选
          ...WordDifficulty.values.map((difficulty) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_getDifficultyName(difficulty)),
                  selected: _selectedDifficulty == difficulty,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? difficulty : null;
                    });
                    _applyFilters();
                  },
                  backgroundColor: _getDifficultyColor(difficulty).withOpacity(0.1),
                  selectedColor: _getDifficultyColor(difficulty).withOpacity(0.3),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '总计',
              '${_statistics['bookmarked'] ?? 0}',
              Colors.blue,
            ),
            _buildStatItem(
              '已掌握',
              '${_bookmarkedWords.where((w) => w.learningStatus == LearningStatus.mastered).length}',
              Colors.green,
            ),
            _buildStatItem(
              '学习中',
              '${_bookmarkedWords.where((w) => w.learningStatus == LearningStatus.learning).length}',
              Colors.orange,
            ),
            _buildStatItem(
              '复习中',
              '${_bookmarkedWords.where((w) => w.learningStatus == LearningStatus.reviewing).length}',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty || _selectedCategory.isNotEmpty ||
        _selectedStatus != null || _selectedDifficulty != null) {
      // 搜索/筛选无结果
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到匹配的单词',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试修改搜索条件或筛选条件',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              text: '清除筛选',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = '';
                  _selectedStatus = null;
                  _selectedDifficulty = null;
                });
                _applyFilters();
              },
            ),
          ],
        ),
      );
    }

    // 空收藏状态
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有收藏任何单词',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击单词卡片上的收藏按钮来收藏喜欢的单词',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: '去学习单词',
            icon: Icons.school,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList() {
    if (_isGridView) {
      return _buildGridView();
    } else {
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredWords.length,
      itemBuilder: (context, index) {
        final word = _filteredWords[index];
        return _buildWordListItem(word, index);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredWords.length,
      itemBuilder: (context, index) {
        final word = _filteredWords[index];
        return _buildWordGridItem(word, index);
      },
    );
  }

  Widget _buildWordListItem(Word word, int index) {
    final isSelected = _selectedWordIds.contains(word.id);
    
    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) {
          _enterSelectionMode();
        }
        _toggleWordSelection(word.id);
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleWordSelection(word.id);
        } else {
          widget.onWordTap?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _isSelectionMode && isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: _isSelectionMode && isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            if (_isSelectionMode)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleWordSelection(word.id),
                ),
              ),
            Expanded(
              child: WordCard(
                word: word,
                isInteractive: !_isSelectionMode,
                width: double.infinity,
                height: 120,
                onBookmarkToggle: () {
                  _loadBookmarkedWords();
                  _loadStatistics();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordGridItem(Word word, int index) {
    final isSelected = _selectedWordIds.contains(word.id);
    
    return GestureDetector(
      onLongPress: () {
        if (!_isSelectionMode) {
          _enterSelectionMode();
        }
        _toggleWordSelection(word.id);
      },
      onTap: () {
        if (_isSelectionMode) {
          _toggleWordSelection(word.id);
        } else {
          widget.onWordTap?.call();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isSelectionMode && isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(12),
          border: _isSelectionMode && isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            WordCard(
              word: word,
              isInteractive: !_isSelectionMode,
              width: double.infinity,
              height: double.infinity,
              onBookmarkToggle: () {
                _loadBookmarkedWords();
                _loadStatistics();
              },
            ),
            if (_isSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleWordSelection(word.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: '取消收藏 (${_selectedWordIds.length})',
                icon: Icons.bookmark_remove,
                onPressed: _selectedWordIds.isNotEmpty ? _batchUnbookmark : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: '开始复习',
                icon: Icons.play_arrow,
                onPressed: _selectedWordIds.isNotEmpty ? _startReview : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusName(LearningStatus status) {
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

  Color _getStatusColor(LearningStatus status) {
    switch (status) {
      case LearningStatus.notStarted:
        return const Color(0xFF9E9E9E);
      case LearningStatus.learning:
        return const Color(0xFF2196F3);
      case LearningStatus.reviewing:
        return const Color(0xFFFF9800);
      case LearningStatus.mastered:
        return const Color(0xFF4CAF50);
    }
  }

  String _getDifficultyName(WordDifficulty difficulty) {
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

  Color _getDifficultyColor(WordDifficulty difficulty) {
    switch (difficulty) {
      case WordDifficulty.beginner:
        return const Color(0xFF4CAF50);
      case WordDifficulty.elementary:
        return const Color(0xFF2196F3);
      case WordDifficulty.intermediate:
        return const Color(0xFFFF9800);
      case WordDifficulty.advanced:
        return const Color(0xFFE53935);
    }
  }
}