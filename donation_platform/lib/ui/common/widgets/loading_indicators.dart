import 'package:flutter/material.dart';
import 'package:donation_platform/config/themes.dart';

/// A simple circular loading spinner
class LoadingSpinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  
  const LoadingSpinner({
    super.key,
    this.size = 36.0,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppThemes.primaryColor,
        ),
      ),
    );
  }
}

/// A loading indicator with a message
class LoadingIndicator extends StatelessWidget {
  final String message;
  final double spinnerSize;
  
  const LoadingIndicator({
    super.key,
    this.message = 'Loading...',
    this.spinnerSize = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingSpinner(size: spinnerSize),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// A pulsating loading dot animation
class PulsatingDots extends StatefulWidget {
  final Color? color;
  final double size;
  
  const PulsatingDots({
    super.key,
    this.color,
    this.size = 10.0,
  });

  @override
  State<PulsatingDots> createState() => _PulsatingDotsState();
}

class _PulsatingDotsState extends State<PulsatingDots> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  
  final int _numDots = 3;
  final double _delayFactor = 0.3;
  
  @override
  void initState() {
    super.initState();
    
    _animationControllers = List.generate(
      _numDots,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    
    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    // Start animations with delays
    for (int i = 0; i < _numDots; i++) {
      Future.delayed(
        Duration(milliseconds: (i * _delayFactor * 500).round()),
        () {
          if (mounted) {
            _animationControllers[i].repeat(reverse: true);
          }
        },
      );
    }
  }
  
  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_numDots, (index) {
        return AnimatedBuilder(
          animation: _animationControllers[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: widget.size * _animations[index].value,
              width: widget.size * _animations[index].value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color ?? AppThemes.primaryColor,
              ),
            );
          },
        );
      }),
    );
  }
}

/// A shimmer loading placeholder for lists, cards, etc.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  
  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
    
    _controller.repeat();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}