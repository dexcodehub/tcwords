import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/achievement_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';
import 'package:tcword/src/services/game_engine_service.dart';
import 'package:tcword/src/widgets/game_base_widget.dart';

/// 现代化单词匹配游戏 - 使用新的游戏引擎技术
class WordMatchingGameV2 extends GameBaseWidget {
  WordMatchingGameV2({super.key})
      : super(
          gameTitle: '单词配对大师',
          primaryColor: const Color(0xFFFF6B6B),
          secondaryColor: const Color(0xFFFF8E53),
          difficulty: AdaptiveDifficulty(initialDifficulty: 0.5),
        );

  @override
  Widget buildGameContent(BuildContext context, GameBaseState state) {
    // 具体实现在状态类中
    return const SizedBox();
  }

  @override
  Widget buildGameControls(BuildContext context, GameBaseState state) {
    // 具体实现在状态类中
    return const SizedBox();
  }

  @override
  State<WordMatchingGameV2> createState() => _WordMatchingGameV2State();
}

class _WordMatchingGameV2State extends GameBaseState<WordMatchingGameV2> {
  final WordService _wordService = WordService();
  final List<AnimationController> _optionAnimations = [];
  final List<Animation<double>> _optionScales = [];
  final List<Animation<Color?>> _optionColors = [];

  List<Word> _words = [];
  List<Word> _questionWords = [];
  List<Word> _optionWords = [];
  Word? _currentWord;
  bool _showResult = false;
  bool _isCorrect = false;
  String? _errorMessage;

  late AnimationController _questionAnimation;
  late Animation<double> _questionScale;
  // late Animation<Color?> _questionColor; // 暂时注释未使用的变量

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWords();
  }

  void _initializeAnimations() {
    _questionAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _questionScale = GameEngineService.createBounceAnimation(_questionAnimation);
    // _questionColor = GameEngineService.createColorTransitionAnimation(
    //   _questionAnimation,
    //   const Color(0xFF64B5F6),
    //   const Color(0xFF42A5F5),
    // );
  }

  @override
  void onGameInitialized() {
    _prepareQuestion();
  }

  Future<void> _loadWords() async {
    try {
      final words = await _wordService.getAllWords();
      if (words.isEmpty) {
        setState(() {
          _errorMessage = '没有可用的单词进行游戏';
        });
        return;
      }

      setState(() {
        _words = words;
      });
      
      _prepareQuestion();
    } catch (e) {
      setState(() {
        _errorMessage = '加载单词时出错: $e';
      });
    }
  }

  void _prepareQuestion() {
    if (_words.length < 4) {
      setState(() {
        _errorMessage = '可用单词数量不足，无法开始游戏';
      });
      return;
    }

    // 根据难度生成游戏参数
    final params = widget.difficulty.generateGameParameters();
    final optionsCount = params['optionsCount'] as int;

    // 随机选择单词
    final shuffledWords = List<Word>.from(_words)..shuffle();
    _questionWords = shuffledWords.take(optionsCount).toList();
    _currentWord = _questionWords[0];
    _optionWords = List<Word>.from(_questionWords)..shuffle();

    // 初始化选项动画
    _initializeOptionAnimations();

    setState(() {
      _showResult = false;
      _isCorrect = false;
      _errorMessage = null;
    });

    // 播放问题出现动画
    _questionAnimation.reset();
    _questionAnimation.forward();
  }

  void _initializeOptionAnimations() {
    // 清理旧的动画控制器
    for (final controller in _optionAnimations) {
      controller.dispose();
    }
    _optionAnimations.clear();
    _optionScales.clear();
    _optionColors.clear();

    // 创建新的动画控制器
    for (int i = 0; i < _optionWords.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

      final scale = GameEngineService.createBounceAnimation(controller);
      final color = GameEngineService.createColorTransitionAnimation(
        controller,
        _getOptionColor(i),
        _getOptionColor(i).withValues(alpha: 0.8),
      );

      _optionAnimations.add(controller);
      _optionScales.add(scale);
      _optionColors.add(color);

      // 延迟播放动画，创建波浪效果
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) controller.forward();
      });
    }
  }

  Color _getOptionColor(int index) {
    const colors = [
      Color(0xFF4CAF50),
      Color(0xFF2196F3),
      Color(0xFFFF9800),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }

  void _checkAnswer(Word selectedWord) {
    onUserInteraction();
    incrementAttempts();

    final isCorrect = selectedWord.id == _currentWord?.id;
    final responseTime = 1.0; // 简化响应时间计算

    // 调整难度
    widget.difficulty.adjustDifficulty(isCorrect, responseTime);

    setState(() {
      _showResult = true;
      _isCorrect = isCorrect;
    });

    // 播放反馈动画
    _playFeedbackAnimation(isCorrect);

    if (isCorrect) {
      updateScore(10);
      
      // 触发成就事件
      AchievementServiceSingleton.instance.processEvent(
        AchievementEvent(type: AchievementEventType.wordLearned),
      );

      // 检查是否达到完美得分
      if (score > 0 && attempts == score) {
        AchievementServiceSingleton.instance.processEvent(
          AchievementEvent(type: AchievementEventType.perfectScore),
        );
      }

      // 检查是否升级
      if (score % 50 == 0) {
        levelUp();
      }
    }

    // 延迟进入下一题
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _prepareQuestion();
    });
  }

  void _playFeedbackAnimation(bool isCorrect) {
    // 播放选项动画
    for (int i = 0; i < _optionAnimations.length; i++) {
      final word = _optionWords[i];
      if (word.id == _currentWord?.id) {
        // 正确答案的动画
        _optionAnimations[i].reset();
        _optionAnimations[i].forward();
      } else if (!isCorrect) {
        // 错误答案的动画
        _optionAnimations[i].reset();
        _optionAnimations[i].forward();
      }
    }
  }

  Widget _buildWordImage(Word word) {
    return AnimatedBuilder(
      animation: _questionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _questionScale.value,
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF64B5F6),
                  const Color(0xFF42A5F5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  spreadRadius: 3,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _getWordImageContent(word),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getWordImageContent(Word word) {
    try {
      return Image.asset(
        word.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return SimpleIcons.getIcon(word.text, size: 80);
        },
      );
    } catch (e) {
      return SimpleIcons.getIcon(word.text, size: 80);
    }
  }

  Widget _buildOptionButton(int index, Word word) {
    final isCorrectAnswer = word.id == _currentWord?.id;
    final isSelected = _showResult && isCorrectAnswer;

    return AnimatedBuilder(
      animation: _optionAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _optionScales[index].value,
          child: GameCard(
            backgroundColor: _optionColors[index].value ?? _getOptionColor(index),
            onTap: _showResult ? null : () => _checkAnswer(word),
            isSelected: isSelected,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showResult && isCorrectAnswer)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                if (_showResult && !isCorrectAnswer)
                  const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                if (_showResult) const SizedBox(width: 8),
                Text(
                  word.text.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedback() {
    if (!_showResult) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isCorrect
              ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
              : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.3),
            spreadRadius: 3,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCorrect ? Icons.star : Icons.favorite,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isCorrect ? '太棒了！+10分 🎉' : '继续加油！ 💪',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildGameContent(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            GameButton(
              text: '重试',
              icon: Icons.refresh,
              color: const Color(0xFFFF6B6B),
              onPressed: _loadWords,
            ),
          ],
        ),
      );
    }

    if (_currentWord == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 问题单词
        _buildWordImage(_currentWord!),
        const SizedBox(height: 32),
        
        // 选项按钮
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(_optionWords.length, (index) {
            return _buildOptionButton(index, _optionWords[index]);
          }),
        ),
        
        const SizedBox(height: 24),
        
        // 反馈信息
        _buildFeedback(),
      ],
    );
  }

  @override
  Widget buildGameControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GameButton(
          text: '提示',
          icon: Icons.lightbulb,
          color: const Color(0xFFFF9800),
          onPressed: () {
            // 提示功能实现
          },
        ),
        GameButton(
          text: '跳过',
          icon: Icons.skip_next,
          color: const Color(0xFF2196F3),
          onPressed: _prepareQuestion,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _questionAnimation.dispose();
    for (final controller in _optionAnimations) {
      controller.dispose();
    }
    super.dispose();
  }
}