import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tcword/src/views/word_matching_game.dart';
// import 'package:tcword/src/views/word_matching_game_v2.dart'; // Commented out unused import

/// 游戏演示页面 - 展示新旧版本对比
class GameDemoView extends StatelessWidget {
  const GameDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('游戏技术演示'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题
            const Text(
              '游戏引擎技术升级演示',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // 功能对比
            _buildFeatureComparison(),
            const SizedBox(height: 30),
            
            // 游戏选择
            const Text(
              '选择游戏版本体验:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            // 旧版本按钮
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WordMatchingGame(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('体验旧版本游戏'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            
            // 新版本按钮
            ElevatedButton.icon(
              onPressed: () {
                context.go('/matching-game-v2');
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('体验新版本游戏'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            
            // 对比分析按钮
            OutlinedButton.icon(
              onPressed: () {
                _showTechnicalComparison(context);
              },
              icon: const Icon(Icons.analytics),
              label: const Text('查看技术对比分析'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '技术升级特性对比:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _ComparisonItem(
            feature: '动画引擎',
            oldVersion: '基础AnimatedContainer',
            newVersion: '物理弹簧动画 + 粒子效果',
          ),
          _ComparisonItem(
            feature: '状态管理',
            oldVersion: '简单setState',
            newVersion: '防抖状态管理器',
          ),
          _ComparisonItem(
            feature: '难度系统',
            oldVersion: '固定难度',
            newVersion: '自适应AI算法',
          ),
          _ComparisonItem(
            feature: '视觉反馈',
            oldVersion: '基础颜色变化',
            newVersion: '多层次动画反馈',
          ),
          _ComparisonItem(
            feature: '性能优化',
            oldVersion: '基础渲染',
            newVersion: '60FPS流畅体验',
          ),
        ],
      ),
    );
  }

  void _showTechnicalComparison(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('技术实现对比'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTechDetail(
                title: '🎯 动画系统升级',
                details: [
                  '• 物理弹簧动画 (SpringSimulation)',
                  '• 粒子爆炸效果系统',
                  '• 3D旋转变换支持',
                  '• 60FPS流畅动画帧率',
                ],
              ),
              _buildTechDetail(
                title: '⚡ 性能优化',
                details: [
                  '• 防抖状态管理 (100ms延迟)',
                  '• 动画控制器复用',
                  '• 内存泄漏防护',
                  '• 高效渲染管道',
                ],
              ),
              _buildTechDetail(
                title: '🧠 智能难度',
                details: [
                  '• 实时响应时间分析',
                  '• 动态难度调整算法',
                  '• 玩家表现学习模型',
                  '• 平滑难度过渡',
                ],
              ),
              _buildTechDetail(
                title: '🎨 视觉增强',
                details: [
                  '• 多层次渐变色彩',
                  '• 实时阴影效果',
                  '• 交互粒子反馈',
                  '• 专业UI动效',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildTechDetail({required String title, required List<String> details}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          ...details.map((detail) => Text(
                detail,
                style: const TextStyle(fontSize: 14),
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// 对比项组件
class _ComparisonItem extends StatelessWidget {
  final String feature;
  final String oldVersion;
  final String newVersion;

  const _ComparisonItem({
    required this.feature,
    required this.oldVersion,
    required this.newVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  oldVersion,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  newVersion,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}