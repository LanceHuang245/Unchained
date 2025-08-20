// widgets/terminal.dart

import 'package:flutter/material.dart';
import 'package:unchained/classes/log_formatter.dart';

class Terminal extends StatelessWidget {
  final List<String> lines;
  final ScrollController scrollController;

  const Terminal({
    super.key,
    required this.lines,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          controller: scrollController,
          itemCount: lines.length,
          itemBuilder: (context, idx) {
            final parts = lines[idx].split('|');
            final time = parts[0];
            final level = parts[1];
            final content = parts[2];

            final Color levelColor = LogFormatter.formatLevel(level);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Consolas',
                  ),
                  children: [
                    if (time.isNotEmpty)
                      TextSpan(
                        text: '$time  ',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    if (level.isNotEmpty)
                      TextSpan(
                        text: '$level  ',
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    TextSpan(text: content),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
