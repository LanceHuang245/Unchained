import 'package:fluent_ui/fluent_ui.dart';

class Terminal extends StatelessWidget {
  final List<String> lines;
  final bool visible;

  const Terminal({Key? key, required this.lines, required this.visible})
      : super(key: key);

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
                color: FluentTheme.of(context)
                    .resources
                    .controlStrokeColorDefault),
            borderRadius: BorderRadius.circular(8)),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: lines.length,
          itemBuilder: (context, idx) {
            final parts = lines[idx].split('|');
            final time = parts[0];
            final level = parts[1];
            final content = parts[2];

            Color levelColor;
            switch (level) {
              case 'WARNING':
                levelColor = Colors.red;
                break;
              case 'ERROR':
                levelColor = Colors.red;
                break;
              case 'INFO':
              default:
                levelColor = Colors.green;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 14,
                    color: FluentTheme.of(context)
                        .resources
                        .textOnAccentFillColorPrimary,
                  ),
                  children: [
                    if (time.isNotEmpty)
                      TextSpan(
                        text: '$time  ',
                        style: TextStyle(
                          color: FluentTheme.of(context)
                              .resources
                              .textFillColorTertiary,
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
                          color: FluentTheme.of(context).inactiveColor),
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
