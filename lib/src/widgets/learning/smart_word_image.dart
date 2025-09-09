import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/ai_image_service.dart';
import '../../models/word.dart';

/// 智能单词图片组件
/// 自动为单词生成AI图片或显示预设图片
class SmartWordImage extends StatefulWidget {
  final Word word;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableAIGeneration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final VoidCallback? onImageGenerated;
  
  const SmartWordImage({
    super.key,
    required this.word,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableAIGeneration = true,
    this.placeholder,
    this.errorWidget,
    this.onImageGenerated,
  });

  @override
  State<SmartWordImage> createState() => _SmartWordImageState();
}

class _SmartWordImageState extends State<SmartWordImage> {
  String? _aiImagePath;
  bool _isGenerating = false;
  bool _hasError = false;
  final AIImageService _aiService = AIImageServiceSingleton.instance.service;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  
  Future<void> _loadImage() async {
    // 首先尝试加载预设图片
    if (widget.word.imagePath.isNotEmpty && await _imageExists(widget.word.imagePath)) {
      return; // 预设图片存在，直接使用
    }
    
    // 如果启用AI生成且预设图片不存在
    if (widget.enableAIGeneration) {
      await _generateAIImage();
    }
  }
  
  Future<bool> _imageExists(String imagePath) async {
    try {
      if (imagePath.startsWith('assets/')) {
        // 资源文件，假设存在（运行时会处理错误）
        return true;
      } else {
        // 本地文件
        return await File(imagePath).exists();
      }
    } catch (e) {
      return false;
    }
  }
  
  Future<void> _generateAIImage() async {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
      _hasError = false;
    });
    
    try {
      final imagePath = await _aiService.generateImageForWord(widget.word);
      
      if (mounted) {
        setState(() {
          _aiImagePath = imagePath;
          _isGenerating = false;
          _hasError = imagePath == null;
        });
        
        if (imagePath != null && widget.onImageGenerated != null) {
          widget.onImageGenerated!();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _hasError = true;
        });
      }
    }
  }
  
  Widget _buildImage() {
    // 优先使用AI生成的图片
    if (_aiImagePath != null) {
      return Image.file(
        File(_aiImagePath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
    
    // 使用预设图片
    if (widget.word.imagePath.isNotEmpty) {
      if (widget.word.imagePath.startsWith('assets/')) {
        return Image.asset(
          widget.word.imagePath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
        );
      } else {
        return Image.file(
          File(widget.word.imagePath),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) => _buildFallbackWidget(),
        );
      }
    }
    
    // 没有图片时的处理
    return _buildFallbackWidget();
  }
  
  Widget _buildLoadingWidget() {
    return widget.placeholder ?? Container(
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '生成中...',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Container(
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            '生成失败',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFallbackWidget() {
    // 如果正在生成AI图片，显示加载状态
    if (_isGenerating) {
      return _buildLoadingWidget();
    }
    
    // 如果生成失败，显示错误状态
    if (_hasError) {
      return _buildErrorWidget();
    }
    
    // 默认显示单词文字图标
    return Container(
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(widget.word.category),
            size: (widget.width ?? 100) * 0.4,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          if (widget.enableAIGeneration)
            GestureDetector(
              onTap: _generateAIImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '生成图片',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'animals':
        return Icons.pets;
      case 'food':
        return Icons.restaurant;
      case 'nature':
        return Icons.nature;
      case 'objects':
        return Icons.category;
      case 'people':
        return Icons.person;
      case 'places':
        return Icons.place;
      case 'actions':
        return Icons.directions_run;
      case 'colors':
        return Icons.palette;
      case 'numbers':
        return Icons.numbers;
      case 'time':
        return Icons.access_time;
      default:
        return Icons.book;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _buildImage(),
    );
  }
}

/// AI图片设置面板组件
class AIImageSettingsPanel extends StatefulWidget {
  const AIImageSettingsPanel({super.key});

  @override
  State<AIImageSettingsPanel> createState() => _AIImageSettingsPanelState();
}

class _AIImageSettingsPanelState extends State<AIImageSettingsPanel> {
  final AIImageService _aiService = AIImageServiceSingleton.instance.service;
  final TextEditingController _apiKeyController = TextEditingController();
  
  String _selectedProvider = 'pollinations';
  bool _cacheEnabled = true;
  bool _serviceAvailable = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkServiceStatus();
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSettings() async {
    final settings = _aiService.getCurrentSettings();
    setState(() {
      _selectedProvider = settings['provider'];
      _cacheEnabled = settings['cacheEnabled'];
      if (settings['hasApiKey']) {
        _apiKeyController.text = '••••••••••••'; // 隐藏实际API Key
      }
    });
  }
  
  Future<void> _checkServiceStatus() async {
    final available = await _aiService.isServiceAvailable();
    setState(() {
      _serviceAvailable = available;
    });
  }
  
  Future<void> _saveProvider(String provider) async {
    await _aiService.setProvider(
      provider,
      apiKey: _apiKeyController.text.isNotEmpty && !_apiKeyController.text.startsWith('•')
          ? _apiKeyController.text
          : null,
    );
    setState(() {
      _selectedProvider = provider;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已切换到${_aiService.getAvailableProviders()[provider]}')),
    );
  }
  
  Future<void> _toggleCache(bool enabled) async {
    await _aiService.setCacheEnabled(enabled);
    setState(() {
      _cacheEnabled = enabled;
    });
  }
  
  Future<void> _clearCache() async {
    await _aiService.clearCache();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存已清理')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final providers = _aiService.getAvailableProviders();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI图片生成设置'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务状态
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _serviceAvailable ? Icons.check_circle : Icons.error,
                      color: _serviceAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _serviceAvailable ? '服务可用' : '服务不可用',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // API提供商选择
            const Text(
              'AI服务提供商',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ...providers.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                subtitle: Text(_getProviderDescription(entry.key)),
                value: entry.key,
                groupValue: _selectedProvider,
                onChanged: (value) {
                  if (value != null) {
                    _saveProvider(value);
                  }
                },
              );
            }),
            
            const SizedBox(height: 16),
            
            // API Key输入（如果需要）
            if (_selectedProvider != 'pollinations') ...[
              const Text(
                'API Key',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  hintText: '输入API Key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
            ],
            
            // 缓存设置
            SwitchListTile(
              title: const Text('启用图片缓存'),
              subtitle: const Text('缓存生成的图片以提高加载速度'),
              value: _cacheEnabled,
              onChanged: _toggleCache,
            ),
            
            const SizedBox(height: 16),
            
            // 清理缓存按钮
            ElevatedButton(
              onPressed: _clearCache,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('清理图片缓存'),
            ),
            
            const Spacer(),
            
            // 说明文字
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '💡 提示：\n'
                '• Pollinations AI：免费服务，无需API Key\n'
                '• Stability AI：需要付费API Key，图片质量更高\n'
                '• Hugging Face：需要免费API Key，速度较快\n'
                '• 生成的图片会自动缓存，避免重复生成',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getProviderDescription(String provider) {
    switch (provider) {
      case 'pollinations':
        return '免费服务，无需API Key';
      case 'stability':
        return '高质量图片，需要付费API Key';
      case 'huggingface':
        return '开源模型，需要免费API Key';
      default:
        return '';
    }
  }
}