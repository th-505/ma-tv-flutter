import 'package:flutter/material.dart';
import '../../domain/models/content_identity.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tv/tv_remote_focus.dart';

class HeroBanner extends StatelessWidget {
  final ContentIdentity content;
  final VoidCallback onPlay;
  final VoidCallback onDetails;

  const HeroBanner({
    super.key,
    required this.content,
    required this.onPlay,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final backdrop = content.canonical.backdropPath != null
        ? 'https://image.tmdb.org/t/p/original${content.canonical.backdropPath}'
        : null;

    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;

    return Container(
      height: desktop ? 520 : 420,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (backdrop != null)
            Image.network(
              backdrop,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.darkElevated),
            )
          else
            Container(color: AppColors.darkElevated),

          // Cinematic Gradients (Bottom and Right for RTL)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Content Information
          Positioned(
            bottom: desktop ? 44 : 24,
            right: desktop ? 48 : 20,
            left: desktop ? width * 0.35 : 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.canonical.title,
                  style: const TextStyle(
                    fontSize: desktop ? 38 : 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (content.canonical.overview.isNotEmpty)
                  Text(
                    content.canonical.overview,
                    maxLines: desktop ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: desktop ? 15 : 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    TvFocusableWidget(
                      onSelect: onPlay,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.gold400,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, color: Colors.black, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'تشغيل سريع',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TvFocusableWidget(
                      onSelect: onDetails,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'تفاصيل أكثر',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
