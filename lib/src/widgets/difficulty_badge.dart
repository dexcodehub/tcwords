import 'package:flutter/material.dart';
import '../models/course_model.dart';

class DifficultyBadge extends StatelessWidget {
  final DifficultyLevel level;
  final bool compact;
  final double? fontSize;
  final EdgeInsets? padding;

  const DifficultyBadge({
    super.key,
    required this.level,
    this.compact = false,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getDifficultyColors(level);
    final text = _getDifficultyText(level);
    final icon = _getDifficultyIcon(level);

    return Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Icon(
              icon,
              color: Colors.white,
              size: fontSize != null ? fontSize! + 2 : 16,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? (compact ? 12 : 14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  DifficultyColors _getDifficultyColors(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return DifficultyColors(
          primary: Colors.green[500]!,
          secondary: Colors.green[700]!,
        );
      case DifficultyLevel.elementary:
        return DifficultyColors(
          primary: Colors.blue[500]!,
          secondary: Colors.blue[700]!,
        );
      case DifficultyLevel.intermediate:
        return DifficultyColors(
          primary: Colors.orange[500]!,
          secondary: Colors.orange[700]!,
        );
      case DifficultyLevel.upperIntermediate:
        return DifficultyColors(
          primary: Colors.purple[500]!,
          secondary: Colors.purple[700]!,
        );
      case DifficultyLevel.advanced:
        return DifficultyColors(
          primary: Colors.red[500]!,
          secondary: Colors.red[700]!,
        );
    }
  }

  String _getDifficultyText(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return '入门';
      case DifficultyLevel.elementary:
        return '初级';
      case DifficultyLevel.intermediate:
        return '中级';
      case DifficultyLevel.upperIntermediate:
        return '中高级';
      case DifficultyLevel.advanced:
        return '高级';
    }
  }

  IconData _getDifficultyIcon(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Icons.school;
      case DifficultyLevel.elementary:
        return Icons.menu_book;
      case DifficultyLevel.intermediate:
        return Icons.psychology;
      case DifficultyLevel.upperIntermediate:
        return Icons.emoji_objects;
      case DifficultyLevel.advanced:
        return Icons.military_tech;
    }
  }
}

class DifficultyColors {
  final Color primary;
  final Color secondary;

  const DifficultyColors({
    required this.primary,
    required this.secondary,
  });
}

class AnimatedDifficultyBadge extends StatefulWidget {
  final DifficultyLevel level;
  final bool compact;
  final double? fontSize;
  final EdgeInsets? padding;
  final Duration animationDuration;

  const AnimatedDifficultyBadge({
    super.key,
    required this.level,
    this.compact = false,
    this.fontSize,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedDifficultyBadge> createState() => _AnimatedDifficultyBadgeState();
}

class _AnimatedDifficultyBadgeState extends State<AnimatedDifficultyBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: DifficultyBadge(
              level: widget.level,
              compact: widget.compact,
              fontSize: widget.fontSize,
              padding: widget.padding,
            ),
          ),
        );
      },
    );
  }
}

class DifficultyProgressBadge extends StatelessWidget {
  final DifficultyLevel currentLevel;
  final DifficultyLevel targetLevel;
  final double progress;
  final bool showProgress;

  const DifficultyProgressBadge({
    super.key,
    required this.currentLevel,
    required this.targetLevel,
    required this.progress,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DifficultyBadge(
              level: currentLevel,
              compact: true,
            ),
            if (currentLevel != targetLevel) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.6,
                child: DifficultyBadge(
                  level: targetLevel,
                  compact: true,
                ),
              ),
            ],
          ],
        ),
        if (showProgress && currentLevel != targetLevel) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getDifficultyColor(targetLevel),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% 到下一级别',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Color _getDifficultyColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return Colors.green[500]!;
      case DifficultyLevel.elementary:
        return Colors.blue[500]!;
      case DifficultyLevel.intermediate:
        return Colors.orange[500]!;
      case DifficultyLevel.upperIntermediate:
        return Colors.purple[500]!;
      case DifficultyLevel.advanced:
        return Colors.red[500]!;
    }
  }
}