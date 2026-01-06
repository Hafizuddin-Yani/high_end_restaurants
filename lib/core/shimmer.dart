import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// High-end shimmer/skeleton loading effects
class LuxeShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const LuxeShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    ).animate(onPlay: (c) => c.repeat())
      .shimmer(
        duration: 1500.ms,
        color: const Color(0xFF3A3A3A),
      );
  }
}

/// Skeleton loader for package cards
class PackageCardSkeleton extends StatelessWidget {
  const PackageCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image skeleton
          const LuxeShimmer(
            height: 200,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LuxeShimmer(width: 180, height: 24),
                    LuxeShimmer(
                      width: 80,
                      height: 24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Description skeleton
                const LuxeShimmer(height: 14),
                const SizedBox(height: 8),
                const LuxeShimmer(width: 200, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for booking cards
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image skeleton
              const LuxeShimmer(
                width: 70,
                height: 70,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 16),
              // Details skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LuxeShimmer(width: 140, height: 18),
                    const SizedBox(height: 8),
                    const LuxeShimmer(width: 180, height: 14),
                    const SizedBox(height: 8),
                    LuxeShimmer(
                      width: 80,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LuxeShimmer(
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(8),
              ),
              Row(
                children: [
                  LuxeShimmer(
                    width: 60,
                    height: 32,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(width: 8),
                  LuxeShimmer(
                    width: 60,
                    height: 32,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton list builder
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsetsGeometry? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 3,
    required this.itemBuilder,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Profile skeleton
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar skeleton
          const LuxeShimmer(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          const SizedBox(height: 16),
          // Name skeleton
          const LuxeShimmer(width: 150, height: 24),
          const SizedBox(height: 8),
          // Email skeleton
          const LuxeShimmer(width: 200, height: 16),
          const SizedBox(height: 32),
          // Menu items skeleton
          ...List.generate(4, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LuxeShimmer(
              height: 56,
              borderRadius: BorderRadius.circular(12),
            ),
          )),
        ],
      ),
    );
  }
}

/// Inline shimmer for text
class TextShimmer extends StatelessWidget {
  final double width;
  final double height;

  const TextShimmer({
    super.key,
    this.width = 100,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LuxeShimmer(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// Circular shimmer for avatars
class AvatarShimmer extends StatelessWidget {
  final double size;

  const AvatarShimmer({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return LuxeShimmer(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

