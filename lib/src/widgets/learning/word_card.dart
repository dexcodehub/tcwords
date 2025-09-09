import 'package:flutter/material.dart';
import '../../models/word.dart';
import '../../models/course_model.dart';
import '../../services/tts_service.dart';
import '../../services/word_service.dart';
import '../custom_button.dart';
import '../difficulty_badge.dart';
import 'static_word_image.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final VoidCallback? onFlip;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onStatusUpdate;
  final bool showAnswer;
  final bool isInteractive;
  final double? width;
  final double? height;

  const WordCard({
    super.key,
    required this.word,
    this.onFlip,
    this.onBookmarkToggle,
    this.onStatusUpdate,
    this.showAnswer = false,
    this.isInteractive = true,
    this.width,
    this.height,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  bool _isPlaying = false;
  final WordService _wordService = WordService();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // 如果初始状态为显示答案，直接翻转
    if (widget.showAnswer) {
      _isFlipped = true;
      _flipController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    // 停止TTS播放
    TTSService.stop();
    super.dispose();
  }

  void _handleFlip() {
    if (!widget.isInteractive) return;

    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }

    widget.onFlip?.call();
  }

  Future<void> _handleSpeak() async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    try {
      await TTSService.speak(widget.word.text);
    } catch (e) {
      // TTS服务可能不可用，静默处理
      debugPrint('TTS Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _handleBookmarkToggle() async {
    if (!widget.isInteractive) return;

    try {
      await _wordService.toggleBookmark(widget.word.id);
      widget.onBookmarkToggle?.call();
    } catch (e) {
      debugPrint('Bookmark Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    final cardWidth = widget.width ?? size.width * 0.85;
    final cardHeight = widget.height ?? size.height * 0.6;

    return Center(
      child: GestureDetector(
        onTap: _handleFlip,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value < 0.5;
            
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * 3.14159),
              child: Container(
                width: cardWidth,
                height: cardHeight,
                child: isShowingFront
                    ? _buildFrontCard(theme, cardWidth, cardHeight)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _buildBackCard(theme, cardWidth, cardHeight),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard(ThemeData theme, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.word.getDifficultyColor().withOpacity(0.1),
            widget.word.getDifficultyColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.word.getDifficultyColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部状态栏
          _buildTopBar(theme),
          
          // 主要内容区域
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 智能图片区域
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: StaticWordImage(
                    word: widget.word,
                    width: width * 0.6,
                    height: height * 0.25,
                    fit: BoxFit.cover,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 单词文本
                Flexible(
                  child: Text(
                    widget.word.text,
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.word.getDifficultyColor(),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 分类标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.word.category.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 操作按钮
                _buildActionButtons(theme),
              ],
            ),
          ),
          
          // 底部提示
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '点击卡片查看含义',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(ThemeData theme, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.word.getStatusColor().withOpacity(0.1),
            widget.word.getStatusColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.word.getStatusColor().withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 顶部状态栏
          _buildTopBar(theme),
          
          // 主要内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 单词（小字）
                    Text(
                      widget.word.text,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: widget.word.getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 含义
                    if (widget.word.meaning != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          widget.word.meaning!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // 例句
                    if (widget.word.example != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.word.getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '例句',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: widget.word.getStatusColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.word.example!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // 学习状态更新按钮
                    _buildLearningActions(theme),
                  ],
                ),
              ),
            ),
          ),
          
          // 底部提示
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '再次点击返回正面',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 难度标签
          DifficultyBadge(
            level: _difficultyToLevel(widget.word.difficulty),
            compact: true,
          ),
          
          const Spacer(),
          
          // 学习状态指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.word.getStatusColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.word.getStatusName(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.word.getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 收藏按钮
          if (widget.isInteractive)
            GestureDetector(
              onTap: _handleBookmarkToggle,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.word.isBookmarked
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.word.isBookmarked 
                      ? Icons.bookmark 
                      : Icons.bookmark_border,
                  size: 20,
                  color: widget.word.isBookmarked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 发音按钮
        CustomButton(
          text: _isPlaying ? '播放中...' : '发音',
          icon: _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
          onPressed: _isPlaying ? null : _handleSpeak,
          isLoading: _isPlaying,
          backgroundColor: widget.word.getDifficultyColor(),
          width: 120,
          height: 48,
        ),
      ],
    );
  }

  Widget _buildLearningActions(ThemeData theme) {
    if (!widget.isInteractive) return const SizedBox.shrink();
    
    return Column(
      children: [
        Text(
          '学习状态',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildStatusButton(
              theme,
              '继续学习',
              LearningStatus.learning,
              Icons.school_outlined,
            ),
            _buildStatusButton(
              theme,
              '需要复习',
              LearningStatus.reviewing,
              Icons.refresh_outlined,
            ),
            _buildStatusButton(
              theme,
              '已掌握',
              LearningStatus.mastered,
              Icons.check_circle_outline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    ThemeData theme,
    String label,
    LearningStatus status,
    IconData icon,
  ) {
    final isSelected = widget.word.learningStatus == status;
    final color = _getStatusColor(status);
    
    return GestureDetector(
      onTap: () => _updateLearningStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.2)
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: color, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLearningStatus(LearningStatus status) async {
    try {
      await _wordService.updateLearningStatus(widget.word.id, status);
      widget.onStatusUpdate?.call();
    } catch (e) {
      debugPrint('Status Update Error: $e');
    }
  }

  Color _getStatusColor(LearningStatus status) {
    switch (status) {
      case LearningStatus.learning:
        return const Color(0xFF2196F3);
      case LearningStatus.reviewing:
        return const Color(0xFFFF9800);
      case LearningStatus.mastered:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  // 将WordDifficulty转换为DifficultyLevel（用于DifficultyBadge）
  dynamic _difficultyToLevel(WordDifficulty difficulty) {
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
}