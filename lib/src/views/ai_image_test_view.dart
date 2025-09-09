import 'package:flutter/material.dart';
import 'dart:io';
import '../services/ai_image_service.dart';
import '../models/word.dart';

/// AI图片生成测试页面
class AIImageTestView extends StatefulWidget {
  const AIImageTestView({super.key});

  @override
  State<AIImageTestView> createState() => _AIImageTestViewState();
}

class _AIImageTestViewState extends State<AIImageTestView> {
  final AIImageService _aiService = AIImageServiceSingleton.instance.service;
  final TextEditingController _wordController = TextEditingController();
  
  String? _generatedImagePath;
  bool _isGenerating = false;
  String _statusMessage = '等待输入单词...';
  
  // 测试单词列表
  final List<String> _testWords = [
    'car', 'dog', 'cat', 'house', 'tree', 'sun', 'moon', 'star',
    'flower', 'bird', 'fish', 'apple', 'book', 'phone', 'computer'
  ];
  
  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }
  
  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }
  
  Future<void> _checkServiceStatus() async {
    final isAvailable = await _aiService.isServiceAvailable();
    final settings = _aiService.getCurrentSettings();
    
    setState(() {
      _statusMessage = isAvailable 
          ? '服务可用 - 当前提供商: ${settings['providerName']}'
          : '服务不可用，请检查网络连接';
    });
  }
  
  Future<void> _generateImage(String word) async {
    if (word.trim().isEmpty) return;
    
    setState(() {
      _isGenerating = true;
      _generatedImagePath = null;
      _statusMessage = '正在为 \"$word\" 生成图片...';
    });
    
    try {
      // 创建测试单词对象
      final testWord = Word(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        text: word,
        category: 'test',
        imagePath: '',
        audioPath: '',
        meaning: '测试单词',
      );
      
      final imagePath = await _aiService.generateImageForWord(testWord);
      
      if (mounted) {
        setState(() {
          _generatedImagePath = imagePath;
          _isGenerating = false;
          _statusMessage = imagePath != null 
              ? '✅ 图片生成成功！'
              : '❌ 图片生成失败，请检查网络或更换服务提供商';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _statusMessage = '❌ 生成失败: $e';
        });
      }
    }
  }
  
  Future<void> _clearCache() async {
    await _aiService.clearCache();
    setState(() {
      _statusMessage = '🗑️ 缓存已清理';
      _generatedImagePath = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI图片生成测试'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCache,
            tooltip: '清理缓存',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 服务状态
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 服务状态',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _checkServiceStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('检查服务状态'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎨 输入单词生成图片',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _wordController,
                      decoration: const InputDecoration(
                        hintText: '输入英文单词，例如: cat, dog, car...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => _generateImage(value),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : () => _generateImage(_wordController.text),
                      icon: _isGenerating 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? '生成中...' : '生成图片'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 快速测试按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🚀 快速测试',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _testWords.map((word) {
                        return ElevatedButton(
                          onPressed: _isGenerating ? null : () => _generateImage(word),
                          child: Text(word),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 生成的图片
            if (_generatedImagePath != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🖼️ 生成的图片',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Center(
                            child: Image.file(
                              File(_generatedImagePath!),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '图片显示失败',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_isGenerating)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(_statusMessage),
                        const SizedBox(height: 8),
                        const Text(
                          '首次生成可能需要10-30秒，请耐心等待...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 16),
                child: Card(
                  color: Colors.grey.shade50,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '等待生成图片...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}