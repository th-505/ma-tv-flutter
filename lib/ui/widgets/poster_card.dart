import 'package:flutter/material.dart';
import '../../domain/models/content_identity.dart';
import '../../core/tv/tv_remote_focus.dart';
import '../../core/theme/app_theme.dart';
import 'custom_badge.dart';

class PosterCard extends StatelessWidget {
  final ContentIdentity identity;
  final VoidCallback onTap;
  final double width;
  final double height;

  const PosterCard({
    super.key,
    required this.identity,
    required this.onTap,
    this.width = 135,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = identity.canonical.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${identity.canonical.posterPath}'
        : null;

    return TvFocusableWidget(
      onSelect: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.darkElevated,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster Image
            if (posterUrl != null)
              Image.network(
                posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallback(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: AppColors.darkElevated,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold400,
                      ),
                    ),
                  );
                },
              )
            else
              _buildFallback(),

            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 70,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Vote Average Badge
            if (identity.canonical.voteAverage != null && identity.canonical.voteAverage! > 0)
              Positioned(
                top: 8,
                left: 8,
                child: CustomBadge(
                  isGold: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 10, color: AppColors.gold400),
                      const SizedBox(width: 3),
                      Text(identity.canonical.voteAverage!.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ),

            // Title
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                identity.canonical.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.darkElevated,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.movie, color: AppColors.gold400, size: 30),
              const SizedBox(height: 6),
              Text(
                identity.canonical.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Cairo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
