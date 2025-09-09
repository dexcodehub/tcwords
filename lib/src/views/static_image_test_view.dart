import 'package:flutter/material.dart';
import '../services/static_word_image_service.dart';
import '../widgets/learning/static_word_image.dart';
import '../models/word.dart';

/// 静态图片测试页面
class StaticImageTestView extends StatefulWidget {
  const StaticImageTestView({super.key});

  @override
  State<StaticImageTestView> createState() => _StaticImageTestViewState();
}

class _StaticImageTestViewState extends State<StaticImageTestView> {
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  
  // 测试单词列表
  final List<String> _testWords = [
    'car', 'cat', 'dog', 'apple', 'banana', 'train', 'bus', 'bird', 'fish', 'red', 'blue', 'green'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }
  
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await StaticWordImageService.instance.initialize();
      final stats = StaticWordImageService.instance.getStatistics();
      
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('加载统计失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('静态图片测试'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 统计信息
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📊 服务状态',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('总图片数: ${_statistics?['total'] ?? 0}'),
                          Text('初始化状态: ${_statistics?['initialized'] == true ? '✅ 已初始化' : '❌ 未初始化'}'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 测试图片网格
                  const Text(
                    '🖼️ 图片测试',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _testWords.length,
                    itemBuilder: (context, index) {
                      final word = _testWords[index];
                      final testWord = Word(
                        id: 'test_$index',
                        text: word,
                        category: 'test',
                        imagePath: '',
                        audioPath: '',
                      );
                      
                      return Card(
                        elevation: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: StaticWordImage(
                                word: testWord,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                word,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 路径测试
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔍 路径测试',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._testWords.map((word) {
                            final path = StaticWordImageService.instance.getImagePath(word);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text('$word: ${path ?? "❌ 未找到"}'),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}