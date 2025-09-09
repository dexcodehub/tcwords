import 'package:flutter/material.dart';
import '../models/achievement.dart';

/// 成就卡片组件
class AchievementCard extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onTap;
  final bool showProgress;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
    this.showProgress = true,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: _getCardGradient(),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor().withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _buildCardContent(),
            ),
          );
        },
      ),
    );
  }

  /// 构建卡片内容
  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 4),
                _buildDescription(),
                if (widget.showProgress && !widget.achievement.isUnlocked) ...[
                  const SizedBox(height: 12),
                  _buildProgressBar(),
                ],
                const SizedBox(height: 8),
                _buildRewards(),
              ],
            ),
          ),
          _buildStatusIcon(),
        ],
      ),
    );
  }

  /// 构建图标
  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: widget.achievement.isUnlocked
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              )
            : LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[400]!],
              ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        widget.achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
        size: 30,
        color: Colors.white,
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.achievement.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.achievement.isUnlocked ? Colors.white : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildDifficultyBadge(),
      ],
    );
  }

  /// 构建描述
  Widget _buildDescription() {
    return Text(
      widget.achievement.description,
      style: TextStyle(
        fontSize: 14,
        color: widget.achievement.isUnlocked 
            ? Colors.white.withOpacity(0.9) 
            : Colors.grey[500],
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    final progress = widget.achievement.overallProgress;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建奖励信息
  Widget _buildRewards() {
    if (widget.achievement.rewards.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: widget.achievement.rewards.take(3).map((reward) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRewardIcon(reward.type),
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '${reward.value}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 构建难度徽章
  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getDifficultyColor().withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        _getDifficultyText(),
        style: TextStyle(
          fontSize: 10,
          color: _getDifficultyColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建状态图标
  Widget _buildStatusIcon() {
    if (widget.achievement.isUnlocked) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 20,
        ),
      );
    } else if (widget.achievement.overallProgress > 0) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.trending_up,
          color: Colors.white,
          size: 20,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.lock_outline,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
      );
    }
  }

  /// 获取卡片渐变色
  LinearGradient _getCardGradient() {
    if (widget.achievement.isUnlocked) {
      switch (widget.achievement.difficulty) {
        case AchievementDifficulty.easy:
          return const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          );
        case AchievementDifficulty.medium:
          return const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
          );
        case AchievementDifficulty.hard:
          return const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
          );
        case AchievementDifficulty.legendary:
          return const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          );
      }
    } else {
      return LinearGradient(
        colors: [Colors.grey[400]!, Colors.grey[500]!],
      );
    }
  }

  /// 获取发光颜色
  Color _getGlowColor() {
    if (widget.achievement.isUnlocked) {
      switch (widget.achievement.difficulty) {
        case AchievementDifficulty.easy:
          return const Color(0xFF4CAF50);
        case AchievementDifficulty.medium:
          return const Color(0xFFFF9800);
        case AchievementDifficulty.hard:
          return const Color(0xFFE91E63);
        case AchievementDifficulty.legendary:
          return const Color(0xFF9C27B0);
      }
    } else {
      return Colors.grey;
    }
  }

  /// 获取难度颜色
  Color _getDifficultyColor() {
    switch (widget.achievement.difficulty) {
      case AchievementDifficulty.easy:
        return Colors.green;
      case AchievementDifficulty.medium:
        return Colors.orange;
      case AchievementDifficulty.hard:
        return Colors.red;
      case AchievementDifficulty.legendary:
        return Colors.purple;
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
}