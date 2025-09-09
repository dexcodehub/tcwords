import 'package:flutter/material.dart';
import 'package:tcword/src/models/word.dart';
import 'package:tcword/src/services/word_service.dart';
import 'package:tcword/src/services/audio_service.dart';
import 'package:tcword/src/utils/simple_icons.dart';
import 'package:tcword/src/widgets/learning/static_word_image.dart';
import 'dart:math' as math;

class WordLearningView extends StatefulWidget {
  const WordLearningView({super.key});

  @override
  State<WordLearningView> createState() => _WordLearningViewState();
}

class _WordLearningViewState extends State<WordLearningView>
    with TickerProviderStateMixin {
  final WordService _wordService = WordService();
  List<Word> _words = [];
  int _currentIndex = 0;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _starController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _starAnimation;
  bool _showStars = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
    
    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _starController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    final words = await _wordService.getAllWords();
    setState(() {
      _words = words;
    });
  }

  void _nextWord() {
    if (_words.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _showStars = false;
    });
    _slideController.forward(from: 0.0);
    _bounceController.forward(from: 0.0);
  }

  void _previousWord() {
    if (_words.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _words.length) % _words.length;
      _showStars = false;
    });
    _slideController.forward(from: 0.0);
    _bounceController.forward(from: 0.0);
  }

  void _playSound() async {
    if (_words.isEmpty) return;
    
    // 播放音效时显示星星动画
    setState(() {
      _showStars = true;
    });
    _starController.forward(from: 0.0);
    
    // 直接使用TTS朗读单词，因为我们不需要预置音频文件
    await AudioService.speak(_words[_currentIndex].text);
    
    // 延迟后隐藏星星
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showStars = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 单词学习 🌟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _words.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 进度指示器
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_currentIndex + 1} / ${_words.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 200,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[300],
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (_currentIndex + 1) / _words.length,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 单词图片（带动画效果）
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: ScaleTransition(
                            scale: _bounceAnimation,
                            child: Container(
                              height: 250,
                              width: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFEB3B), Color(0xFFFFC107)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: StaticWordImage(
                                  word: _words[_currentIndex],
                                  width: 240,
                                  height: 240,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(30),
                                  fallback: Center(
                                    child: SimpleIcons.getIcon(
                                      _words[_currentIndex].text,
                                      size: 120,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // 星星动画效果
                        if (_showStars)
                          ...List.generate(6, (index) {
                            final angle = (index * 60) * math.pi / 180;
                            return AnimatedBuilder(
                              animation: _starAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    math.cos(angle) * 80 * _starAnimation.value,
                                    math.sin(angle) * 80 * _starAnimation.value,
                                  ),
                                  child: Transform.scale(
                                    scale: _starAnimation.value,
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // 单词文本
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        _words[_currentIndex].text.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 中文翻译
                     Text(
                       _getChineseTranslation(_words[_currentIndex].text),
                       style: const TextStyle(
                         fontSize: 24,
                         fontWeight: FontWeight.w600,
                         color: Color(0xFF1976D2),
                       ),
                     ),
                    
                    const SizedBox(height: 40),
                    
                    // 控制按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 上一个按钮
                        _buildControlButton(
                          icon: Icons.arrow_back_ios,
                          color: const Color(0xFF2196F3),
                          onPressed: _previousWord,
                        ),
                        
                        // 播放按钮
                        _buildControlButton(
                          icon: Icons.volume_up,
                          color: const Color(0xFFFF9800),
                          onPressed: _playSound,
                          size: 70,
                        ),
                        
                        // 下一个按钮
                        _buildControlButton(
                          icon: Icons.arrow_forward_ios,
                          color: const Color(0xFF4CAF50),
                          onPressed: _nextWord,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
   }
   
   String _getChineseTranslation(String word) {
     // 简单的英中翻译映射
     const translations = {
       'car': '汽车',
       'truck': '卡车',
       'bus': '公交车',
       'bike': '自行车',
       'train': '火车',
       'slide': '滑梯',
       'swing': '秋千',
       'seesaw': '跷跷板',
       'dog': '狗',
       'cat': '猫',
       'elephant': '大象',
       'lion': '狮子',
       'monkey': '猴子',
       'bird': '鸟',
       'fish': '鱼',
       'red': '红色',
       'blue': '蓝色',
       'green': '绿色',
       'yellow': '黄色',
       'orange': '橙色',
       'one': '一',
       'two': '二',
       'three': '三',
       'four': '四',
       'five': '五',
       'apple': '苹果',
       'banana': '香蕉',
       'bread': '面包',
       'milk': '牛奶',
       'egg': '鸡蛋',
       'head': '头',
       'hand': '手',
       'foot': '脚',
       'eye': '眼睛',
       'nose': '鼻子',
       'ball': '球',
       'doll': '娃娃',
       'toy_car': '玩具车',
       'blocks': '积木',
       'teddy bear': '泰迪熊',
     };
     
     return translations[word.toLowerCase()] ?? word;
   }
 }