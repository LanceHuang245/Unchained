import 'package:fluent_ui/fluent_ui.dart';
import 'package:unchained/classes/log_formatter.dart';

class Terminal extends StatelessWidget {
  final List<String> lines;
  final bool visible;

  const Terminal({super.key, required this.lines, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          border: Border.all(
            color: FluentTheme.of(context).resources.controlStrokeColorDefault,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: lines.length,
          itemBuilder: (context, idx) {
            final parts = lines[idx].split('|');
            final time = parts[0];
            final level = parts[1];
            final content = parts[2];

            Color levelColor;
            levelColor = LogFormatter.formatLevel(level);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 14,
                    color: FluentTheme.of(
                      context,
                    ).resources.textOnAccentFillColorPrimary,
                  ),
                  children: [
                    if (time.isNotEmpty)
                      TextSpan(
                        text: '$time  ',
                        style: TextStyle(
                          color: FluentTheme.of(
                            context,
                          ).resources.textFillColorTertiary,
                        ),
                      ),
                    if (level.isNotEmpty)
                      TextSpan(
                        text: '$level  ',
                        style: TextStyle(
                          color: levelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    TextSpan(
                      text: content,
                      style: TextStyle(
                        color: FluentTheme.of(context).inactiveColor,
                      ),
                    ),
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
