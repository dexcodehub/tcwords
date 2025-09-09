import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// 游戏引擎服务 - 提供现代化的游戏动画和交互效果
class GameEngineService {
  static final GameEngineService _instance = GameEngineService._internal();
  factory GameEngineService() => _instance;
  GameEngineService._internal();

  /// 弹簧物理动画控制器
  static AnimationController createSpringAnimationController(
    TickerProvider vsync, {
    double springDescription = 1.0,
    double dampingRatio = 0.5,
    double velocity = 0.0,
  }) {
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: springDescription * 100,
      damping: dampingRatio * 2.0 * sqrt(springDescription * 100),
    );

    final simulation = SpringSimulation(
      spring,
      0.0,
      1.0,
      velocity,
    );

    return AnimationController.unbounded(
      vsync: vsync,
    )..animateWith(simulation);
  }

  /// 创建弹跳动画效果
  static Animation<double> createBounceAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  /// 创建缩放脉冲动画
  static Animation<double> createPulseAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// 创建摇晃动画（用于错误反馈）
  static Animation<double> createShakeAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.1), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: -0.1), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.1), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// 创建粒子爆炸效果
  static List<Animation<Offset>> createParticleAnimations(
    AnimationController controller,
    int particleCount,
    double maxDistance,
  ) {
    final random = Random();
    return List.generate(particleCount, (index) {
      final angle = 2 * pi * random.nextDouble();
      final distance = maxDistance * random.nextDouble();
      final endOffset = Offset(
        distance * cos(angle),
        distance * sin(angle),
      );

      return Tween<Offset>(
        begin: Offset.zero,
        end: endOffset,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(
            index * 0.1 / particleCount,
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      );
    });
  }

  /// 创建颜色渐变动画
  static Animation<Color?> createColorTransitionAnimation(
    AnimationController controller,
    Color beginColor,
    Color endColor,
  ) {
    return ColorTween(begin: beginColor, end: endColor).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// 创建3D旋转动画
  static Animation<double> create3DRotationAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// 创建路径动画（用于特殊移动效果）
  static Animation<Offset> createPathAnimation(
    AnimationController controller,
    Path path,
  ) {
    return Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(1, 1),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }
}

/// 游戏难度自适应算法
class AdaptiveDifficulty {
  final double _initialDifficulty;
  double _currentDifficulty;
  final double _maxDifficulty;
  final double _minDifficulty;
  final double _adjustmentRate;

  AdaptiveDifficulty({
    double initialDifficulty = 0.5,
    double maxDifficulty = 1.0,
    double minDifficulty = 0.1,
    double adjustmentRate = 0.05,
  })  : _initialDifficulty = initialDifficulty.clamp(minDifficulty, maxDifficulty),
        _currentDifficulty = initialDifficulty.clamp(minDifficulty, maxDifficulty),
        _maxDifficulty = maxDifficulty,
        _minDifficulty = minDifficulty,
        _adjustmentRate = adjustmentRate;

  /// 根据玩家表现调整难度
  void adjustDifficulty(bool wasCorrect, double responseTime) {
    if (wasCorrect) {
      // 答对且响应时间快，增加难度
      if (responseTime < 2.0) {
        _currentDifficulty = (_currentDifficulty + _adjustmentRate).clamp(_minDifficulty, _maxDifficulty);
      }
    } else {
      // 答错，降低难度
      _currentDifficulty = (_currentDifficulty - _adjustmentRate).clamp(_minDifficulty, _maxDifficulty);
    }
  }

  /// 获取当前难度级别
  double get currentDifficulty => _currentDifficulty;

  /// 重置难度到初始值
  void reset() {
    _currentDifficulty = _initialDifficulty;
  }

  /// 根据难度生成游戏参数
  Map<String, dynamic> generateGameParameters() {
    return {
      'timeLimit': 10.0 * (1.0 - _currentDifficulty) + 3.0, // 3-10秒时间限制
      'optionsCount': (4 + (_currentDifficulty * 2)).round(), // 4-6个选项
      'similarityThreshold': _currentDifficulty * 0.8, // 选项相似度阈值
    };
  }
}

/// 高性能游戏状态管理器
class GameStateManager<T> {
  final Map<String, T> _state = {};
  final List<Function(Map<String, T>)> _listeners = [];
  final Duration _debounceDuration;

  GameStateManager({Duration debounceDuration = const Duration(milliseconds: 100)})
      : _debounceDuration = debounceDuration;

  /// 设置状态（带防抖）
  void setState(String key, T value, {bool immediate = false}) {
    _state[key] = value;
    if (immediate) {
      _notifyListeners();
    } else {
      _debounce(_notifyListeners);
    }
  }

  /// 获取状态
  T? getState(String key) => _state[key];

  /// 添加状态监听器
  void addListener(Function(Map<String, T>) listener) {
    _listeners.add(listener);
  }

  /// 移除状态监听器
  void removeListener(Function(Map<String, T>) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(Map.from(_state));
    }
  }

  Timer? _debounceTimer;
  void _debounce(Function callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () => callback());
  }

  /// 清空所有状态
  void clear() {
    _state.clear();
    _notifyListeners();
  }
}

/// 视觉反馈系统
class VisualFeedbackSystem {
  static const Map<String, Color> _feedbackColors = {
    'success': Color(0xFF4CAF50),
    'error': Color(0xFFF44336),
    'warning': Color(0xFFFF9800),
    'info': Color(0xFF2196F3),
    'neutral': Color(0xFF9E9E9E),
  };

  static const Map<String, IconData> _feedbackIcons = {
    'success': Icons.check_circle,
    'error': Icons.error,
    'warning': Icons.warning,
    'info': Icons.info,
    'neutral': Icons.help,
  };

  /// 获取反馈颜色
  static Color getColor(String type) => _feedbackColors[type] ?? _feedbackColors['neutral']!;

  /// 获取反馈图标
  static IconData getIcon(String type) => _feedbackIcons[type] ?? _feedbackIcons['neutral']!;

  /// 创建反馈动画序列
  static List<Animation<double>> createFeedbackAnimations(AnimationController controller) {
    return [
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      ),
      Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(0.7, 1.0, curve: Curves.easeIn),
        ),
      ),
    ];
  }

  /// 创建分数浮动动画
  static Animation<Offset> createScoreFloatAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ),
    );
  }
}