import 'package:flutter/material.dart';
import 'package:tcword/src/views/ai_image_test_view.dart';
import 'package:tcword/src/widgets/learning/word_card.dart';
import 'package:tcword/src/widgets/learning/vocabulary_quiz.dart';
import 'package:tcword/src/widgets/learning/word_bookmark.dart';
import 'package:tcword/src/widgets/learning/word_search_bar.dart';
import 'package:tcword/src/widgets/learning/smart_word_image.dart';
import 'package:tcword/src/widgets/learning/static_word_image.dart';
import 'package:tcword/src/views/static_image_test_view.dart';
import 'package:tcword/src/views/word_matching_game.dart';
import 'package:tcword/src/views/puzzle_game.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/models/learning/quiz_models.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/progress_service.dart';
import 'package:tcword/src/services/storage_service.dart';
import 'package:tcword/src/models/user_progress.dart' as progress_model;
import 'package:tcword/src/models/user_model.dart';
import 'package:tcword/src/widgets/custom_button.dart';

class LearningCenterView extends StatefulWidget {
  const LearningCenterView({super.key});

  @override
  State<LearningCenterView> createState() => _LearningCenterViewState();
}

class _LearningCenterViewState extends State<LearningCenterView> with TickerProviderStateMixin {
  final WordService _wordService = WordService();
  final StorageService _storageService = StorageService();
  
  List<Word> _words = [];
  List<Word> _todayWords = [];
  progress_model.UserProgress? _userProgress;
  User? _currentUser;
  bool _isLoading = true;
  bool _isGuestMode = false;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // 加载用户状态
      final user = await _storageService.getCurrentUser();
      final isGuest = await _storageService.isGuestMode();
      
      // 加载单词数据
      final words = await _wordService.getAllWords();
      
      // 加载进度数据（游客模式下用默认值）
      progress_model.UserProgress? progress;
      if (!isGuest && user != null) {
        try {
          progress = await ProgressService.getProgress();
        } catch (e) {
          print('加载进度数据失败: $e');
        }
      }
      
      // 选择今日学习的单词（随机选择5个）
      final shuffledWords = List<Word>.from(words)..shuffle();
      final todayWords = shuffledWords.take(5).toList();
      
      setState(() {
        _currentUser = user;
        _isGuestMode = isGuest;
        _words = words;
        _todayWords = todayWords;
        _userProgress = progress;
        _isLoading = false;
      });
      
      // 启动动画
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('加载数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading your learning journey...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头部欢迎区域
                      _buildWelcomeHeader(),
                      
                      const SizedBox(height: 20),
                      
                      // 每日目标进度
                      _buildDailyProgress(),
                      
                      const SizedBox(height: 24),
                      
                      // 今日学习单词
                      _buildTodayLearning(),
                      
                      const SizedBox(height: 24),
                      
                      // 学习模式选择
                      _buildLearningModes(),
                      
                      const SizedBox(height: 24),
                      
                      // 游戏模式
                      _buildGameModes(),
                      
                      const SizedBox(height: 24),
                      
                      // 学习工具
                      _buildLearningTools(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final points = _userProgress?.totalPoints ?? 0;
    final completedWords = _userProgress?.completedWords.length ?? 0;
    
    // 根据用户状态展示不同内容
    final isGuest = _isGuestMode;
    final userDisplayName = _currentUser?.displayName ?? '游客';
    final welcomeText = isGuest ? '欢迎体验 TCWord！' : 'TCWord 学习中心';
    final subtitleText = isGuest 
        ? '作为游客体验所有功能，注册账户保存学习进度'
        : '欢迎回来！继续你的英语学习之旅';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGuest 
              ? [const Color(0xFFFF9800), const Color(0xFFFF6F00)] // 游客模式用橙色
              : [const Color(0xFF2196F3), const Color(0xFF1976D2)], // 登录用户用蓝色
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isGuest ? Colors.orange : Colors.blue).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 学校图标 - 明确的入口指示
              GestureDetector(
                onTap: () => _navigateToSchool(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isGuest ? Icons.explore : Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isGuest ? '探索' : '学校',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      welcomeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitleText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // 用户状态显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGuest ? Icons.person_outline : Icons.star,
                      color: isGuest ? Colors.white : Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isGuest ? '游客' : '$points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 快速入口按钮组
          Row(
            children: [
              _buildQuickEntryButton(
                icon: isGuest ? Icons.explore_outlined : Icons.school_outlined,
                label: isGuest ? '探索功能' : '进入学校',
                color: Colors.white,
                onTap: () => _navigateToSchool(),
              ),
              const SizedBox(width: 12),
              _buildQuickEntryButton(
                icon: Icons.menu_book,
                label: '开始学习',
                color: Colors.green.shade300,
                onTap: () => _navigateToWordCards(),
              ),
              const SizedBox(width: 12),
              _buildQuickEntryButton(
                icon: isGuest ? Icons.login : Icons.emoji_events,
                label: isGuest ? '登录注册' : '成就系统',
                color: isGuest ? Colors.lightBlue.shade300 : Colors.orange.shade300,
                onTap: isGuest ? () => _navigateToLogin() : () => _navigateToAchievements(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isGuest 
                ? '游客模式下可体验所有功能 | 点击“登录注册”保存进度'
                : '已掌握 $completedWords 个单词 | 点击“进入学校”查看课程',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickEntryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyProgress() {
    final target = 10; // 每日目标：学习10个单词
    final current = _userProgress?.completedWords.length ?? 0;
    final todayProgress = (current % target) / target;
    
    // 游客模式显示不同的内容
    if (_isGuestMode) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.explore, color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  '游客体验模式',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '免费',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '作为游客，你可以体验所有学习功能！',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '注册账户后可以：\n• 保存学习进度\n• 获得成就奖励\n• 参与排行榜竞争',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }
    
    // 登录用户显示正常的进度
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text(
                '今日目标',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(current % target)}/$target',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: todayProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            todayProgress >= 1.0 ? '🎉 今日目标已完成！' : '继续努力，你快达成今日目标了！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLearning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '今日推荐学习',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _todayWords.length,
            itemBuilder: (context, index) {
              final word = _todayWords[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: WordCard(
                  word: word,
                  height: 240,
                  onFlip: () {
                    // 记录学习进度
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLearningModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_book, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text(
              '学习模式',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isGuestMode 
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isGuestMode ? '游客可体验' : '点击卡片开始学习',
                style: TextStyle(
                  fontSize: 12,
                  color: _isGuestMode ? Colors.orange : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildModeCard(
              title: '单词卡片',
              subtitle: '翻转学习单词',
              icon: Icons.flip_to_front,
              color: Colors.blue,
              onTap: () => _navigateToWordCards(),
              badge: _isGuestMode ? '可体验' : '热门',
            ),
            _buildModeCard(
              title: '词汇测验',
              subtitle: '智能测试能力',
              icon: Icons.quiz,
              color: Colors.green,
              onTap: () => _navigateToQuiz(),
              badge: _isGuestMode ? '可体验' : '推荐',
            ),
            _buildModeCard(
              title: '我的收藏',
              subtitle: _isGuestMode ? '需要登录保存' : '复习重点单词',
              icon: Icons.bookmark,
              color: _isGuestMode ? Colors.grey : Colors.purple,
              onTap: () => _isGuestMode ? _showGuestLimitDialog('收藏功能') : _navigateToBookmarks(),
              badge: _isGuestMode ? '限制' : null,
            ),
            _buildModeCard(
              title: '搜索单词',
              subtitle: '快速查找单词',
              icon: Icons.search,
              color: Colors.orange,
              onTap: () => _navigateToSearch(),
              badge: _isGuestMode ? '可体验' : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameModes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.games, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text(
              '游戏模式',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '边玩边学',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGameCard(
                title: '单词配对',
                subtitle: '图文匹配游戏',
                icon: Icons.extension,
                color: Colors.red,
                onTap: () => _navigateToGame(const WordMatchingGame()),
                difficulty: '简单',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGameCard(
                title: '单词拼图',
                subtitle: '字母拼写游戏',
                icon: Icons.games,
                color: Colors.teal,
                onTap: () => _navigateToGame(const PuzzleGame()),
                difficulty: '中等',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLearningTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.build, color: Colors.indigo, size: 24),
            const SizedBox(width: 8),
            const Text(
              '学习工具',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 学习进度工具
        GestureDetector(
          onTap: () {
            print('点击学习进度');
            Navigator.pushNamed(context, '/progress');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学习进度',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '查看详细的学习统计和成就',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.indigo,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // AI图片生成测试页面
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AIImageTestView(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: Colors.pink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AI图片生成测试',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'TEST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '测试AI图片生成功能，诊断问题',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.pink,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 静态图片管理
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StaticImageTestView(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.teal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '静态图片管理',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'FAST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '管理预生成的离线单词图片，快速稳定',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.teal,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // AI图片生成设置
        GestureDetector(
          onTap: _navigateToAISettings,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AI图片生成',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '智能为单词生成匹配图片，提升学习效果',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.purple,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        print('点击了学习模式: $title'); // 调试输出
        try {
          onTap();
        } catch (e) {
          print('导航错误: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('导航失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? difficulty,
  }) {
    return GestureDetector(
      onTap: () {
        print('点击了游戏模式: $title'); // 调试输出
        try {
          onTap();
        } catch (e) {
          print('游戏导航错误: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('游戏导航失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                if (difficulty != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        difficulty,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestLimitDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('需要登录'),
          ],
        ),
        content: Text(
          '$featureName需要登录账户才能使用。\n\n登录后你可以：\n• 保存学习进度\n• 收藏单词\n• 获得成就奖励\n• 参与排行榜竞争',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    print('点击登录注册'); // 调试输出
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登录或注册'),
        content: const Text('要保存你的学习进度吗？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('稍后'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以导航到登录页面
              // context.go('/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('登录功能将在未来版本中提供'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('去登录'),
          ),
        ],
      ),
    );
  }

  void _navigateToSchool() {
    print('点击进入学校'); // 调试输出
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('TCWord 学校'),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school,
                      size: 80,
                      color: Color(0xFF2196F3),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '欢迎来到 TCWord 学校！',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '这里是你的英语学习中心，提供丰富的课程内容和互动学习体验。\n\n未来我们将提供：\n• 结构化课程体系\n• 个性化学习路径\n• 实时学习反馈\n• 全面的进度跟踪',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    Text(
                      '正在开发中...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAchievements() {
    print('点击成就系统'); // 调试输出
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('成就系统'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 24),
                    Text(
                      '成就系统',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '追踪你的学习成就，完成挑战获得奖励！\n\n即将推出：\n• 学习里程碑\n• 连续学习奖励\n• 成就徽章系统\n• 排行榜竞争',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    Text(
                      '正在开发中...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _navigateToWordCards() {
    if (_todayWords.isEmpty) {
      // 如果没有今日单词，显示提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('暂无可学习的单词，请稍后再试'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('单词卡片学习'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: WordCard(
              word: _todayWords.first,
              onFlip: () {
                print('单词卡片翻转'); // 调试输出
              },
              onBookmarkToggle: () {
                print('切换收藏状态'); // 调试输出
              },
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToQuiz() {
    if (_words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('暂无可测验的单词，请稍后再试'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('词汇测验'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          body: VocabularyQuiz(
            words: _words.take(10).toList(), // 限制10个单词测验
            quizType: QuizType.englishToChinese,
            title: '词汇测验',
            onCompleted: () {
              print('测验完成'); // 调试输出
            },
            onResult: (result) {
              print('测验结果: $result'); // 调试输出
            },
          ),
        ),
      ),
    );
  }

  void _navigateToBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('我的收藏'),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          body: WordBookmark(
            onWordTap: () {
              print('点击收藏单词'); // 调试输出
            },
            onStartReview: () {
              print('开始复习'); // 调试输出
            },
          ),
        ),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('搜索单词'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: WordSearchBar(
            onSearchResults: (results) {
              print('搜索结果: ${results.length} 个单词'); // 调试输出
            },
            onQueryChanged: (query) {
              print('搜索查询: $query'); // 调试输出
            },
            showFilters: true,
            showResults: true,
          ),
        ),
      ),
    );
  }

  void _navigateToGame(Widget game) {
    print('导航到游戏: ${game.runtimeType}'); // 调试输出
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => game),
    ).then((_) {
      print('游戏结束，返回学习中心'); // 调试输出
    });
  }
  
  void _navigateToAISettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AIImageSettingsPanel(),
      ),
    );
  }
}