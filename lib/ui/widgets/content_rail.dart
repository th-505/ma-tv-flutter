import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ContentRail extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onSeeAll;
  final List<Widget> children;

  const ContentRail({
    super.key,
    required this.title,
    this.trailing,
    this.onSeeAll,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Rail Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold400,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'الكل',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.chevron_left, size: 18),
                    ],
                  ),
                )
              else if (trailing != null)
                trailing!,
            ],
          ),
        ),

        // Horizontal List
        SizedBox(
          height: MediaQuery.sizeOf(context).width >= 900 ? 230 : 215,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (_, __) => SizedBox(width: MediaQuery.sizeOf(context).width >= 900 ? 16 : 12),
            itemBuilder: (_, index) => children[index],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
