import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.borderRadius,
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey[300]!;
    final effectiveProgressColor = progressColor ?? theme.primaryColor;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              minHeight: height,
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: percentageStyle ?? TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class CustomCircularProgressIndicator extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const CustomCircularProgressIndicator({
    super.key,
    required this.progress,
    this.size = 60.0,
    this.strokeWidth = 6.0,
    this.backgroundColor,
    this.progressColor,
    this.child,
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey[300]!;
    final effectiveProgressColor = progressColor ?? theme.primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: effectiveBackgroundColor,
              color: effectiveProgressColor,
            ),
          ),
          if (child != null)
            child!
          else if (showPercentage)
            Text(
              '${(progress * 100).toInt()}%',
              style: percentageStyle ?? TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: effectiveProgressColor,
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedProgressIndicator extends StatefulWidget {
  final double progress;
  final Duration duration;
  final Curve curve;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const AnimatedProgressIndicator({
    super.key,
    required this.progress,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.borderRadius,
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomProgressIndicator(
          progress: _animation.value,
          backgroundColor: widget.backgroundColor,
          progressColor: widget.progressColor,
          height: widget.height,
          borderRadius: widget.borderRadius,
          showPercentage: widget.showPercentage,
          percentageStyle: widget.percentageStyle,
        );
      },
    );
  }
}

class SegmentedProgressIndicator extends StatelessWidget {
  final int totalSegments;
  final int completedSegments;
  final double segmentWidth;
  final double segmentHeight;
  final double segmentSpacing;
  final Color? completedColor;
  final Color? incompleteColor;
  final BorderRadius? borderRadius;

  const SegmentedProgressIndicator({
    super.key,
    required this.totalSegments,
    required this.completedSegments,
    this.segmentWidth = 20.0,
    this.segmentHeight = 8.0,
    this.segmentSpacing = 4.0,
    this.completedColor,
    this.incompleteColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveCompletedColor = completedColor ?? theme.primaryColor;
    final effectiveIncompleteColor = incompleteColor ?? Colors.grey[300]!;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(segmentHeight / 2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSegments, (index) {
        final isCompleted = index < completedSegments;
        return Container(
          margin: EdgeInsets.only(
            right: index < totalSegments - 1 ? segmentSpacing : 0,
          ),
          width: segmentWidth,
          height: segmentHeight,
          decoration: BoxDecoration(
            color: isCompleted ? effectiveCompletedColor : effectiveIncompleteColor,
            borderRadius: effectiveBorderRadius,
          ),
        );
      }),
    );
  }
}