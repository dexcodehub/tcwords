import 'package:flutter/material.dart';
import '../../services/static_word_image_service.dart';
import '../../models/word.dart';

/// 静态单词图片组件
/// 显示预生成的单词图片，快速、稳定、离线
class StaticWordImage extends StatefulWidget {
  final Word word;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? fallback;
  final BorderRadius? borderRadius;
  final bool showLoadingIndicator;
  
  const StaticWordImage({
    super.key,
    required this.word,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.fallback,
    this.borderRadius,
    this.showLoadingIndicator = true,
  });

  @override
  State<StaticWordImage> createState() => _StaticWordImageState();
}

class _StaticWordImageState extends State<StaticWordImage> {
  String? _imagePath;
  bool _isLoading = true;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }
  
  @override
  void didUpdateWidget(StaticWordImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.text != widget.word.text) {
      _loadImage();
    }
  }
  
  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // 确保静态图片服务已初始化
      await StaticWordImageService.instance.initialize();
      
      // 获取图片路径
      final imagePath = StaticWordImageService.instance.getImagePathForWord(widget.word);
      
      if (mounted) {
        setState(() {
          _imagePath = imagePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }
  
  Widget _buildLoadingWidget() {
    if (!widget.showLoadingIndicator) {
      return _buildFallbackWidget();
    }
    
    return widget.placeholder ?? Container(
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFallbackWidget() {
    return widget.fallback ?? Container(
      width: widget.width ?? 100,
      height: widget.height ?? 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor().withOpacity(0.1),
            _getCategoryColor().withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: _getCategoryColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            size: (widget.width ?? 100) * 0.4,
            color: _getCategoryColor(),
          ),
          const SizedBox(height: 4),
          Text(
            widget.word.text.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getCategoryColor(),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageWidget() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      child: Image.asset(
        _imagePath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackWidget();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          
          // 显示加载动画
          if (frame == null) {
            return _buildLoadingWidget();
          }
          
          // 图片加载完成，显示淡入动画
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      ),
    );
  }
  
  Color _getCategoryColor() {
    switch (widget.word.category.toLowerCase()) {
      case 'animals':
        return Colors.green;
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'objects':
        return Colors.purple;
      case 'nature':
        return Colors.teal;
      case 'colors':
        return Colors.pink;
      case 'numbers':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon() {
    switch (widget.word.category.toLowerCase()) {
      case 'animals':
        return Icons.pets;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'objects':
        return Icons.category;
      case 'nature':
        return Icons.nature;
      case 'colors':
        return Icons.palette;
      case 'numbers':
        return Icons.numbers;
      case 'actions':
        return Icons.directions_run;
      default:
        return Icons.book;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }
    
    if (_hasError || _imagePath == null) {
      return _buildFallbackWidget();
    }
    
    return _buildImageWidget();
  }
}

/// 静态图片管理面板
class StaticImageManagementPanel extends StatefulWidget {
  const StaticImageManagementPanel({super.key});

  @override
  State<StaticImageManagementPanel> createState() => _StaticImageManagementPanelState();
}

class _StaticImageManagementPanelState extends State<StaticImageManagementPanel> {
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  
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
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('静态图片管理'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (_statistics == null) {
      return const Center(
        child: Text('加载统计信息失败'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总体统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 图片统计',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.image, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '总图片数: ${_statistics!['total']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _statistics!['initialized'] ? Icons.check_circle : Icons.error,
                        color: _statistics!['initialized'] ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '服务状态: ${_statistics!['initialized'] ? '已初始化' : '未初始化'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 分类统计
          if (_statistics!['categories'] != null) ...[
            const Text(
              '📂 分类统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: (_statistics!['categories'] as Map).length,
                itemBuilder: (context, index) {
                  final categories = _statistics!['categories'] as Map<String, int>;
                  final category = categories.keys.elementAt(index);
                  final count = categories[category]!;
                  
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(category).withOpacity(0.2),
                        child: Icon(
                          _getCategoryIconData(category),
                          color: _getCategoryColor(category),
                        ),
                      ),
                      title: Text(category),
                      trailing: Text(
                        '$count 张',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 操作按钮
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '🛠️ 管理操作',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _loadStatistics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('刷新统计'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 这里可以添加更多管理功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('更多管理功能开发中...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('高级设置'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case '动物':
        return Colors.green;
      case '食物':
        return Colors.orange;
      case '交通':
        return Colors.blue;
      case '物品':
        return Colors.purple;
      case '自然':
        return Colors.teal;
      case '颜色':
        return Colors.pink;
      case '数字':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIconData(String category) {
    switch (category) {
      case '动物':
        return Icons.pets;
      case '食物':
        return Icons.restaurant;
      case '交通':
        return Icons.directions_car;
      case '物品':
        return Icons.category;
      case '自然':
        return Icons.nature;
      case '颜色':
        return Icons.palette;
      case '数字':
        return Icons.numbers;
      default:
        return Icons.folder;
    }
  }
}