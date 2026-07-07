import 'package:flutter/material.dart';

class PulseAnimationWrapper extends StatefulWidget {
  final Widget child;
  final bool isAnimating;

  const PulseAnimationWrapper({super.key, required this.child, required this.isAnimating});

  @override
  State<PulseAnimationWrapper> createState() => _PulseAnimationWrapperState();
}

class _PulseAnimationWrapperState extends State<PulseAnimationWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (widget.isAnimating) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant PulseAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.isAnimating ? Tween<double>(begin: 0.5, end: 1.0).animate(_controller) : const AlwaysStoppedAnimation(1.0),
      child: widget.child,
    );
  }
}