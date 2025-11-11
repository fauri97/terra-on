import 'package:app/core/models/report_models.dart';
import 'package:app/widgets/avatar_cicle.dart';
import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  final ReportComment c;

  const CommentTile({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarCircle(avatar: c.authorAvatar, size: 26), // <- mudou
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: c.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: c.text,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
