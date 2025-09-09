import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../viewmodels/achievements_viewmodel.dart';
import '../widgets/achievement_card.dart';

/// 成就展示界面
class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AchievementsViewModel()..initialize(),
      child: Consumer<AchievementsViewModel>(builder: (context, viewModel, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6B73FF),
                  Color(0xFF9B59B6),
                  Color(0xFFE74C3C),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(viewModel),
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabBarView(viewModel),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 构建头部区域
  Widget _buildHeader(AchievementsViewModel viewModel) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _headerAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '我的成就 🏆',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // 平衡左侧按钮
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatsCards(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建统计卡片
  Widget _buildStatsCards(AchievementsViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '已解锁',
            '${viewModel.unlockedCount}/${viewModel.totalCount}',
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '总星星',
            '${viewModel.totalStars}',
            Icons.star,
            Colors.yellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '完成度',
            '${(viewModel.completionPercentage * 100).toInt()}%',
            Icons.trending_up,
            Colors.green,
          ),
        ),
      ],
    );
  }

  /// 构建单个统计卡片
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签栏
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: const Color(0xFF6B73FF),
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: '全部'),
          Tab(text: '学习'),
          Tab(text: '游戏'),
          Tab(text: '特殊'),
        ],
      ),
    );
  }

  /// 构建标签页视图
  Widget _buildTabBarView(AchievementsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementsList(viewModel.visibleAchievements),
          _buildAchievementsList(
            viewModel.getAchievementsByType(AchievementType.learning),
          ),
          _buildAchievementsList(
            viewModel.getAchievementsByType(AchievementType.gaming),
          ),
          _buildAchievementsList(
            viewModel.getAchievementsByType(AchievementType.special),
          ),
        ],
      ),
    );
  }

  /// 构建成就列表
  Widget _buildAchievementsList(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无成就',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '继续学习来解锁更多成就吧！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AchievementCard(
            achievement: achievement,
            onTap: () => _showAchievementDetails(achievement),
          ),
        );
      },
    );
  }

  /// 显示成就详情
  void _showAchievementDetails(Achievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementDetailsSheet(achievement: achievement),
    );
  }
}

/// 成就详情底部弹窗
class AchievementDetailsSheet extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailsSheet({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildConditions(),
                  const SizedBox(height: 24),
                  _buildRewards(),
                  const Spacer(),
                  _buildCloseButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: achievement.isUnlocked
                  ? [Colors.amber, Colors.orange]
                  : [Colors.grey[300]!, Colors.grey[400]!],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getDifficultyText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '成就描述',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          achievement.description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '完成条件',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...achievement.conditions.map((condition) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildConditionItem(condition),
            )),
      ],
    );
  }

  Widget _buildConditionItem(AchievementCondition condition) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getConditionTitle(condition.type),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${condition.currentValue}/${condition.targetValue}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: condition.progressPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              condition.isCompleted ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '奖励',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: achievement.rewards.map((reward) => _buildRewardChip(reward)).toList(),
        ),
      ],
    );
  }

  Widget _buildRewardChip(AchievementReward reward) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF9B59B6)],
        ),
        borderRadius: BorderRadius.circular(20),
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
            '${reward.name} x${reward.value}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B73FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
    );
  }

  Color _getDifficultyColor() {
    switch (achievement.difficulty) {
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

  String _getDifficultyText() {
    switch (achievement.difficulty) {
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

  String _getConditionTitle(String type) {
    switch (type) {
      case 'words_learned':
        return '学习单词数';
      case 'games_completed':
        return '完成游戏数';
      case 'perfect_scores':
        return '完美得分次数';
      case 'fast_completions':
        return '快速完成次数';
      case 'consecutive_correct':
        return '连续正确答题';
      case 'daily_streak':
        return '连续学习天数';
      case 'game_types_played':
        return '游戏类型数';
      case 'badges_collected':
        return '收集徽章数';
      case 'total_stars':
        return '总星星数';
      case 'achievements_unlocked':
        return '解锁成就数';
      default:
        return type;
    }
  }

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