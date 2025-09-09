import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/word.dart';
import '../../models/learning/quiz_models.dart';
import '../../services/tts_service.dart';
import '../../services/word_service.dart';
import '../custom_button.dart';
import '../progress_indicator.dart';

class VocabularyQuiz extends StatefulWidget {
  final List<Word> words;
  final QuizType quizType;
  final String title;
  final int? timeLimit; // 秒数，null表示无限制
  final double passingScore;
  final VoidCallback? onCompleted;
  final Function(QuizResult)? onResult;

  const VocabularyQuiz({
    super.key,
    required this.words,
    required this.quizType,
    required this.title,
    this.timeLimit,
    this.passingScore = 0.6,
    this.onCompleted,
    this.onResult,
  });

  @override
  State<VocabularyQuiz> createState() => _VocabularyQuizState();
}

class _VocabularyQuizState extends State<VocabularyQuiz>
    with TickerProviderStateMixin {
  late QuizSession _session;
  late List<QuizQuestion> _questions;
  late AnimationController _progressController;
  late AnimationController _optionController;
  
  int? _selectedOption;
  bool _showAnswer = false;
  Timer? _timer;
  Timer? _questionTimer;
  DateTime? _questionStartTime;
  bool _isPlaying = false;
  
  // 倒计时
  int _remainingTime = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _initializeAnimations();
    _startTimer();
  }

  void _initializeQuiz() {
    _questions = _generateQuestions();
    _session = QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.title,
      type: widget.quizType,
      questions: _questions,
      startedAt: DateTime.now(),
      timeLimit: widget.timeLimit ?? 0,
      passingScore: widget.passingScore,
    );
    
    if (widget.timeLimit != null) {
      _remainingTime = widget.timeLimit!;
    }
    
    _questionStartTime = DateTime.now();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _optionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _startTimer() {
    if (widget.timeLimit != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _remainingTime--;
            if (_remainingTime <= 0) {
              _finishQuiz();
            }
          });
        }
      });
    }
  }

  List<QuizQuestion> _generateQuestions() {
    final random = Random();
    final allWords = List<Word>.from(widget.words);
    final questions = <QuizQuestion>[];

    for (int i = 0; i < allWords.length; i++) {
      final word = allWords[i];
      final options = _generateOptions(word, allWords);
      
      final question = QuizQuestion(
        id: 'q_${i + 1}',
        type: widget.quizType,
        word: word,
        options: options,
        correctAnswerIndex: _getCorrectAnswerIndex(word, options),
        audioPath: word.audioPath,
      );
      
      questions.add(question);
    }

    // 打乱题目顺序
    questions.shuffle(random);
    return questions;
  }

  List<String> _generateOptions(Word correctWord, List<Word> allWords) {
    final random = Random();
    final options = <String>[];
    
    // 添加正确答案
    String correctAnswer;
    switch (widget.quizType) {
      case QuizType.englishToChinese:
      case QuizType.listeningChoice:
        correctAnswer = correctWord.meaning ?? correctWord.text;
        break;
      case QuizType.chineseToEnglish:
        correctAnswer = correctWord.text;
        break;
      case QuizType.spelling:
        correctAnswer = correctWord.text;
        break;
    }
    options.add(correctAnswer);

    // 添加错误选项
    final otherWords = allWords.where((w) => w.id != correctWord.id).toList();
    while (options.length < 4 && otherWords.isNotEmpty) {
      final randomWord = otherWords[random.nextInt(otherWords.length)];
      String option;
      
      switch (widget.quizType) {
        case QuizType.englishToChinese:
        case QuizType.listeningChoice:
          option = randomWord.meaning ?? randomWord.text;
          break;
        case QuizType.chineseToEnglish:
        case QuizType.spelling:
          option = randomWord.text;
          break;
      }
      
      if (!options.contains(option)) {
        options.add(option);
      }
      otherWords.remove(randomWord);
    }

    // 打乱选项顺序
    options.shuffle(random);
    return options;
  }

  int _getCorrectAnswerIndex(Word word, List<String> options) {
    String correctAnswer;
    switch (widget.quizType) {
      case QuizType.englishToChinese:
      case QuizType.listeningChoice:
        correctAnswer = word.meaning ?? word.text;
        break;
      case QuizType.chineseToEnglish:
      case QuizType.spelling:
        correctAnswer = word.text;
        break;
    }
    return options.indexOf(correctAnswer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionTimer?.cancel();
    _progressController.dispose();
    _optionController.dispose();
    TTSService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = _session.currentQuestion;
    
    if (currentQuestion == null) {
      return _buildResultScreen(theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.timeLimit != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomCircularProgressIndicator(
                progress: _remainingTime / widget.timeLimit!,
                size: 40,
                child: Text(
                  '$_remainingTime',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressSection(theme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionSection(theme, currentQuestion),
                    const SizedBox(height: 30),
                    _buildOptionsSection(theme, currentQuestion),
                    const SizedBox(height: 30),
                    if (_showAnswer) _buildAnswerFeedback(theme, currentQuestion),
                  ],
                ),
              ),
            ),
            _buildBottomActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '题目 ${_session.currentQuestionIndex + 1}/${_session.questions.length}',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${(_session.progress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedProgressIndicator(
            progress: _session.progress,
            duration: const Duration(milliseconds: 500),
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(ThemeData theme, QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getQuestionPrompt(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        
        // 题目内容卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                question.word.getDifficultyColor().withOpacity(0.1),
                question.word.getDifficultyColor().withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: question.word.getDifficultyColor().withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              if (widget.quizType == QuizType.listeningChoice) ...[
                Icon(
                  Icons.volume_up,
                  size: 48,
                  color: question.word.getDifficultyColor(),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: _isPlaying ? '播放中...' : '点击播放',
                  icon: _isPlaying ? Icons.volume_up : Icons.play_arrow,
                  onPressed: _isPlaying ? null : () => _playAudio(question),
                  isLoading: _isPlaying,
                  backgroundColor: question.word.getDifficultyColor(),
                ),
              ] else ...[
                Text(
                  question.getQuestionText(),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: question.word.getDifficultyColor(),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.quizType != QuizType.spelling) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.word.category.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsSection(ThemeData theme, QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择答案:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        ...List.generate(question.options.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOptionButton(theme, question, index),
          );
        }),
      ],
    );
  }

  Widget _buildOptionButton(ThemeData theme, QuizQuestion question, int index) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == question.correctAnswerIndex;
    final isWrong = _showAnswer && isSelected && !isCorrect;
    
    Color? backgroundColor;
    Color? textColor;
    IconData? icon;
    
    if (_showAnswer) {
      if (isCorrect) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check;
      } else if (isWrong) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.close;
      }
    } else if (isSelected) {
      backgroundColor = theme.primaryColor;
      textColor = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: CustomButton(
        text: '${String.fromCharCode(65 + index)}. ${question.options[index]}',
        onPressed: _showAnswer ? null : () => _selectOption(index),
        backgroundColor: backgroundColor,
        textColor: textColor,
        isOutlined: !isSelected && !_showAnswer,
        width: double.infinity,
        icon: icon,
        height: 56,
      ),
    );
  }

  Widget _buildAnswerFeedback(ThemeData theme, QuizQuestion question) {
    final isCorrect = _selectedOption == question.correctAnswerIndex;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '回答正确！' : '回答错误',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              '正确答案：${question.getCorrectAnswer()}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (question.word.example != null) ...[
            const SizedBox(height: 8),
            Text(
              '例句：${question.word.example}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!_showAnswer) ...[
            Expanded(
              child: SecondaryButton(
                text: '跳过',
                onPressed: () => _skipQuestion(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: '提交',
                onPressed: _selectedOption != null ? () => _submitAnswer() : null,
              ),
            ),
          ] else ...[
            Expanded(
              child: PrimaryButton(
                text: _session.currentQuestionIndex + 1 >= _session.questions.length
                    ? '查看结果'
                    : '下一题',
                onPressed: () => _nextQuestion(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultScreen(ThemeData theme) {
    final result = QuizResult.fromSession(_session);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('测验结果'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 分数显示
            CustomCircularProgressIndicator(
              progress: result.accuracy,
              size: 140,
              strokeWidth: 12,
              progressColor: result.getScoreColor(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${result.score}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: result.getScoreColor(),
                    ),
                  ),
                  Text(
                    '分',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    result.getScoreGrade(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: result.getScoreColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 详细统计
            _buildStatCard(theme, result),
            
            const Spacer(),
            
            // 操作按钮
            Row(
              children: [
                if (result.incorrectQuestionIds.isNotEmpty) ...[
                  Expanded(
                    child: SecondaryButton(
                      text: '查看错题',
                      onPressed: () => _showWrongAnswers(),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: PrimaryButton(
                    text: '完成',
                    onPressed: () => _finishQuiz(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, QuizResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              theme,
              '正确率',
              '${(result.accuracy * 100).toInt()}%',
              result.accuracy,
              result.getScoreColor(),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              theme,
              '完成题数',
              '${result.totalQuestions}/${result.totalQuestions}',
              1.0,
              theme.primaryColor,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('用时', style: theme.textTheme.bodyMedium),
                Text(
                  _formatDuration(result.totalTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    ThemeData theme,
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(width: 16),
        Expanded(
          child: CustomProgressIndicator(
            progress: progress,
            height: 6,
            progressColor: color,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getQuestionPrompt() {
    switch (widget.quizType) {
      case QuizType.englishToChinese:
        return '选择下面单词的正确含义：';
      case QuizType.chineseToEnglish:
        return '选择下面含义对应的英文单词：';
      case QuizType.listeningChoice:
        return '听音选择正确含义：';
      case QuizType.spelling:
        return '拼写下面含义对应的单词：';
    }
  }

  void _selectOption(int index) {
    if (!_showAnswer) {
      setState(() {
        _selectedOption = index;
      });
    }
  }

  void _submitAnswer() {
    if (_selectedOption == null) return;
    
    setState(() {
      _showAnswer = true;
    });
    
    final currentQuestion = _session.currentQuestion!;
    final isCorrect = currentQuestion.isCorrect(_selectedOption!);
    final timeSpent = DateTime.now().difference(_questionStartTime!);
    
    final answer = QuizAnswer(
      questionId: currentQuestion.id,
      selectedIndex: _selectedOption!,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
      timeSpent: timeSpent,
    );
    
    _session = _session.addAnswer(answer);
    
    // 播放反馈音效（可选）
    _optionController.forward().then((_) {
      _optionController.reset();
    });
  }

  void _skipQuestion() {
    final currentQuestion = _session.currentQuestion!;
    final timeSpent = DateTime.now().difference(_questionStartTime!);
    
    final answer = QuizAnswer(
      questionId: currentQuestion.id,
      selectedIndex: -1, // -1 表示跳过
      isCorrect: false,
      answeredAt: DateTime.now(),
      timeSpent: timeSpent,
    );
    
    _session = _session.addAnswer(answer);
    _nextQuestion();
  }

  void _nextQuestion() {
    setState(() {
      _selectedOption = null;
      _showAnswer = false;
      _questionStartTime = DateTime.now();
    });
    
    _progressController.forward();
    
    if (_session.isCompleted) {
      _finishQuiz();
    }
  }

  Future<void> _playAudio(QuizQuestion question) async {
    if (_isPlaying) return;
    
    setState(() {
      _isPlaying = true;
    });
    
    try {
      await TTSService.speak(question.word.text);
    } catch (e) {
      debugPrint('Audio play error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _showWrongAnswers() {
    // TODO: 实现错题查看功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('错题查看功能待实现')),
    );
  }

  void _finishQuiz() {
    _timer?.cancel();
    _questionTimer?.cancel();
    
    final result = QuizResult.fromSession(_session);
    widget.onResult?.call(result);
    widget.onCompleted?.call();
    
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}