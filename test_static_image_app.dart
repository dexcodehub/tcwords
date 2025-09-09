import 'package:flutter/material.dart';
import 'package:tcword/src/services/static_word_image_service.dart';
import 'package:tcword/src/widgets/learning/static_word_image.dart';
import 'package:tcword/src/models/word.dart';

void main() {
  runApp(StaticImageTestApp());
}

class StaticImageTestApp extends StatefulWidget {
  @override
  State<StaticImageTestApp> createState() => _StaticImageTestAppState();
}

class _StaticImageTestAppState extends State<StaticImageTestApp> {
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  
  // 测试单词列表
  final List<String> _testWords = [
    'car', 'cat', 'dog', 'apple', 'banana', 'train', 'bus', 'bird', 'fish', 
    'red', 'blue', 'green', 'teddy bear', 'elephant', 'lion'
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
      
      print('🎯 StaticWordImageService 初始化完成');
      print('📊 统计信息: $stats');
      
      // 测试单个单词图片路径
      for (final word in _testWords.take(5)) {
        final path = StaticWordImageService.instance.getImagePath(word);
        print('🔍 $word -> ${path ?? "未找到"}');
      }
      
    } catch (e) {
      print('❌ 加载统计失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '静态图片测试',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('静态图片测试'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 服务状态
          Card(
            color: Colors.teal.shade50,
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
                  const SizedBox(height: 8),
                  if (_statistics != null) ...[
                    Text('总图片数: ${_statistics!['total']}'),
                    Text('初始化状态: ${_statistics!['initialized'] ? "✅ 已初始化" : "❌ 未初始化"}'),
                  ] else
                    const Text('❌ 统计信息加载失败'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 图片网格测试
          const Text(
            '🖼️ 图片测试',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: GridView.builder(
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}