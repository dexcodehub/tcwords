import 'package:flutter/material.dart';
import '../models/achievement.dart';

/// 成就详情弹窗
class AchievementDetailDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementDetailDialog({
    super.key,
    required this.achievement,
  });

  @override
  State<AchievementDetailDialog> createState() => _AchievementDetailDialogState();
}

class _AchievementDetailDialogState extends State<AchievementDetailDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _celebrationController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));
    
    // 启动动画
    _fadeController.forward();
    _slideController.forward();
    
    if (widget.achievement.isUnlocked) {
      _celebrationController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _slideController]),
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildDialog(),
            ),
          ),
        );
      },
    );
  }

  /// 构建弹窗内容
  Widget _buildDialog() {
    return Container(
      margin: const EdgeInsets.all(20),
      constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
      decoration: BoxDecoration(
        gradient: _getDialogGradient(),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildConditions(),
                  const SizedBox(height: 20),
                  _buildRewards(),
                  if (!widget.achievement.isUnlocked) ...[
                    const SizedBox(height: 20),
                    _buildProgress(),
                  ],
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.achievement.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildDifficultyBadge(),
                    const SizedBox(width: 8),
                    _buildStatusBadge(),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图标
  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.2 * _celebrationAnimation.value),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: widget.achievement.isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    )
                  : LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.achievement.isUnlocked
                      ? const Color(0xFFFFD700).withOpacity(0.5)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: widget.achievement.isUnlocked ? 3 : 0,
                ),
              ],
            ),
            child: Icon(
              widget.achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  /// 构建描述
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '成就描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.achievement.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建完成条件
  Widget _buildConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '完成条件',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.achievement.conditions.map((condition) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  condition.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: condition.isCompleted ? Colors.green : Colors.white.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getConditionDescription(condition),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                if (condition.targetValue > 1) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${condition.currentValue}/${condition.targetValue}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  /// 构建奖励
  Widget _buildRewards() {
    if (widget.achievement.rewards.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '奖励',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.achievement.rewards.map((reward) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getRewardIcon(reward.type),
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${reward.value} ${_getRewardTypeName(reward.type)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建进度
  Widget _buildProgress() {
    final progress = widget.achievement.overallProgress;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '完成进度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建底部
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                '关闭',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建难度徽章
  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getDifficultyColor(),
          width: 1,
        ),
      ),
      child: Text(
        _getDifficultyText(),
        style: TextStyle(
          fontSize: 12,
          color: _getDifficultyColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建状态徽章
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.achievement.isUnlocked
            ? Colors.green.withOpacity(0.3)
            : Colors.orange.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.achievement.isUnlocked ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Text(
        widget.achievement.isUnlocked ? '已解锁' : '进行中',
        style: TextStyle(
          fontSize: 12,
          color: widget.achievement.isUnlocked ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 获取弹窗渐变色
  LinearGradient _getDialogGradient() {
    if (widget.achievement.isUnlocked) {
      switch (widget.achievement.difficulty) {
        case AchievementDifficulty.easy:
          return const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case AchievementDifficulty.medium:
          return const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFE65100)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case AchievementDifficulty.hard:
          return const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        case AchievementDifficulty.legendary:
          return const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF4A148C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
      }
    } else {
      return LinearGradient(
        colors: [Colors.grey[600]!, Colors.grey[800]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// 获取难度颜色
  Color _getDifficultyColor() {
    switch (widget.achievement.difficulty) {
      case AchievementDifficulty.easy:
        return Colors.lightGreen;
      case AchievementDifficulty.medium:
        return Colors.amber;
      case AchievementDifficulty.hard:
        return Colors.deepOrange;
      case AchievementDifficulty.legendary:
        return Colors.deepPurple;
    }
  }

  /// 获取难度文本
  String _getDifficultyText() {
    switch (widget.achievement.difficulty) {
      case AchievementDifficulty.easy:
        return '简单';
      case AchievementDifficulty.medium:
        return '中等';
      case AchievementDifficulty.hard:
        return '困难';
      case AchievementDifficulty.legendary:
        return '传奇';
    }
  }

  /// 获取奖励图标
  IconData _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.stars:
        return Icons.star;
      case RewardType.badge:
        return Icons.military_tech;
      case RewardType.title:
        return Icons.title;
      case RewardType.item:
        return Icons.card_giftcard;
    }
  }

  /// 获取奖励类型名称
  String _getRewardTypeName(RewardType type) {
    switch (type) {
      case RewardType.stars:
        return '星星';
      case RewardType.badge:
        return '徽章';
      case RewardType.title:
        return '称号';
      case RewardType.item:
        return '道具';
    }
  }

  /// 获取条件描述
  String _getConditionDescription(AchievementCondition condition) {
    switch (condition.type) {
      case 'words_learned':
        return '学习单词';
      case 'games_played':
        return '完成游戏';
      case 'streak_days':
        return '连续学习天数';
      case 'perfect_games':
        return '完美游戏';
      case 'total_score':
        return '累计得分';
      case 'lesson_completed':
        return '完成课程';
      default:
        return condition.type;
    }
  }
}