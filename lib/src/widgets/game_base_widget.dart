import 'package:flutter/material.dart';
import 'package:tcword/src/services/game_engine_service.dart';

/// 游戏组件基类 - 提供统一的游戏界面和交互基础
abstract class GameBaseWidget extends StatefulWidget {
  final String gameTitle;
  final Color primaryColor;
  final Color secondaryColor;
  final AdaptiveDifficulty difficulty;

  const GameBaseWidget({
    Key? key,
    required this.gameTitle,
    this.primaryColor = const Color(0xFF4CAF50),
    this.secondaryColor = const Color(0xFF66BB6A),
    required this.difficulty,
  }) : super(key: key);

  @override
  State<GameBaseWidget> createState();

  /// 构建游戏内容区域
  Widget buildGameContent(BuildContext context, GameBaseState state);

  /// 构建游戏控制区域
  Widget buildGameControls(BuildContext context, GameBaseState state);
}

/// 游戏基础状态类
abstract class GameBaseState<T extends GameBaseWidget> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late GameStateManager<dynamic> _gameState;
  int score = 0;
  int attempts = 0;
  int level = 1;
  bool isPaused = false;
  DateTime? _lastInteractionTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _gameState = GameStateManager();
    _initializeGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gameState.clear();
    super.dispose();
  }

  /// 初始化游戏
  void _initializeGame() {
    widget.difficulty.reset();
    score = 0;
    attempts = 0;
    level = 1;
    isPaused = false;
    _lastInteractionTime = DateTime.now();
    onGameInitialized();
  }

  /// 游戏初始化完成回调
  void onGameInitialized();

  /// 处理用户交互
  void onUserInteraction() {
    _lastInteractionTime = DateTime.now();
  }

  /// 更新分数
  void updateScore(int points, {bool animate = true}) {
    setState(() {
      score += points;
    });
    if (animate) {
      _playScoreAnimation();
    }
  }

  /// 播放分数动画
  void _playScoreAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  /// 增加尝试次数
  void incrementAttempts() {
    setState(() {
      attempts++;
    });
  }

  /// 升级关卡
  void levelUp() {
    setState(() {
      level++;
    });
    widget.difficulty.adjustDifficulty(true, 1.0); // 增加难度
    _playLevelUpAnimation();
  }

  /// 播放升级动画
  void _playLevelUpAnimation() {
    // 实现升级动画效果
  }

  /// 暂停游戏
  void pauseGame() {
    setState(() {
      isPaused = true;
    });
  }

  /// 继续游戏
  void resumeGame() {
    setState(() {
      isPaused = false;
    });
  }

  /// 重新开始游戏
  void restartGame() {
    _initializeGame();
  }

  /// 构建游戏标题栏
  Widget _buildGameAppBar() {
    return AppBar(
      title: Text(
        widget.gameTitle,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      centerTitle: true,
      backgroundColor: widget.primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.primaryColor, widget.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          onPressed: () {
            if (isPaused) {
              resumeGame();
            } else {
              pauseGame();
            }
          },
          tooltip: isPaused ? '继续游戏' : '暂停游戏',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: restartGame,
          tooltip: '重新开始',
        ),
      ],
    );
  }

  /// 构建游戏状态面板
  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.star,
            label: '得分',
            value: '$score',
            color: const Color(0xFFFFD700),
          ),
          _buildStatItem(
            icon: Icons.extension,
            label: '关卡',
            value: '$level',
            color: const Color(0xFF4CAF50),
          ),
          _buildStatItem(
            icon: Icons.timer,
            label: '尝试',
            value: '$attempts',
            color: const Color(0xFF2196F3),
          ),
          _buildStatItem(
            icon: Icons.auto_awesome,
            label: '难度',
            value: '${(widget.difficulty.currentDifficulty * 100).toInt()}%',
            color: const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  /// 构建单个状态项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 构建游戏内容容器
  Widget _buildGameContentContainer(Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.grey[50]!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 构建游戏内容区域 - 由子类实现
  Widget buildGameContent(BuildContext context);

  /// 构建游戏控制区域 - 由子类实现
  Widget buildGameControls(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGameAppBar() as PreferredSizeWidget?,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              widget.primaryColor.withOpacity(0.1),
              widget.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildGameStats(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildGameContentContainer(buildGameContent(context)),
            ),
            const SizedBox(height: 16),
            buildGameControls(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 游戏按钮组件
class GameButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double width;
  final double height;

  const GameButton({
    Key? key,
    required this.text,
    this.icon,
    this.color = const Color(0xFF4CAF50),
    required this.onPressed,
    this.isEnabled = true,
    this.width = 140,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? LinearGradient(
                colors: [color, Color.lerp(color, Colors.black, 0.1)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: isEnabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 游戏卡片组件
class GameCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final double elevation;
  final BorderRadius borderRadius;

  const GameCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.onTap,
    this.isSelected = false,
    this.elevation = 4,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
            spreadRadius: isSelected ? 2 : 1,
            blurRadius: isSelected ? 10 : 5,
            offset: Offset(0, isSelected ? 6 : 3),
          ),
        ],
        border: isSelected
            ? Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}