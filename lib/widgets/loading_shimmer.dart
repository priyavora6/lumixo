// lib/widgets/loading_shimmer.dart

import 'package:flutter/material.dart';
import 'package:lumixo/utils/colors.dart';

class LoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    Key? key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(_controller);
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.08),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardShimmer extends StatelessWidget {
  const CardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(height: 120, borderRadius: 10),
          SizedBox(height: 10),
          LoadingShimmer(height: 16, width: 150),
          SizedBox(height: 8),
          LoadingShimmer(height: 12, width: 100),
        ],
      ),
    );
  }
}