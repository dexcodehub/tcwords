import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/achievement.dart';

/// 成就解锁动画组件
class AchievementUnlockAnimation extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onAnimationComplete;

  const AchievementUnlockAnimation({
    super.key,
    required this.achievement,
    this.onAnimationComplete,
  });

  @override
  State<AchievementUnlockAnimation> createState() => _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _textController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<Particle> _particles = [];
  final int _particleCount = 20;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    ));
    
    _initializeParticles();
    _startAnimation();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles.clear();
    
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        startX: 0.5,
        startY: 0.5,
        endX: 0.1 + random.nextDouble() * 0.8,
        endY: 0.1 + random.nextDouble() * 0.8,
        color: _getParticleColor(),
        size: 3 + random.nextDouble() * 5,
        delay: random.nextDouble() * 0.5,
      ));
    }
  }

  Color _getParticleColor() {
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFFFA500),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimation() async {
    // 启动主动画
    _mainController.forward();
    
    // 延迟启动粒子动画
    await Future.delayed(const Duration(milliseconds: 300));
    _particleController.forward();
    
    // 延迟启动文字动画
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    
    // 动画完成后的回调
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          widget.onAnimationComplete?.call();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // 粒子效果
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          // 主要内容
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_mainController, _textController]),
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 成就图标
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6 * _glowAnimation.value),
                                blurRadius: 30 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 成就解锁文字
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '🎉 成就解锁 🎉',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              widget.achievement.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Container(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                widget.achievement.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // 奖励展示
                            if (widget.achievement.rewards.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: widget.achievement.rewards.map((reward) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getRewardIcon(reward.type),
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${reward.value}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // 点击关闭
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              onPressed: widget.onAnimationComplete,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.stars:
        return Icons.star;
      case RewardType.badge:
        return Icons.military_tech;
      case RewardType.title:
        return Icons.title;
      case RewardType.item:
        return Icons.card_giftcard;
    }
  }
}

/// 粒子类
class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final Color color;
  final double size;
  final double delay;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
    required this.size,
    required this.delay,
  });
}

/// 粒子绘制器
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedProgress = math.max(0.0, progress - particle.delay).clamp(0.0, 1.0);
      
      if (adjustedProgress <= 0) continue;
      
      final currentX = particle.startX + (particle.endX - particle.startX) * adjustedProgress;
      final currentY = particle.startY + (particle.endY - particle.startY) * adjustedProgress;
      
      final opacity = (1.0 - adjustedProgress).clamp(0.0, 1.0);
      final currentSize = particle.size * (1.0 - adjustedProgress * 0.5);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        currentSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}