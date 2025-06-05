import 'package:fluent_ui/fluent_ui.dart';

class ThemeSettingsWidget extends StatelessWidget {
  final ThemeMode currentMode;
  final Future<void> Function(ThemeMode) onModeChanged;

  const ThemeSettingsWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Expander(
        leading: const Icon(FluentIcons.light),
        header: Padding(
          padding:
              const EdgeInsets.only(left: 5, right: 20, top: 15, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("主题设置"),
              Text(
                "允许用户根据喜好进行主题调整。",
                style: TextStyle(
                  color:
                      FluentTheme.of(context).resources.textFillColorSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  RadioButton(
                    content: const Text('跟随系统'),
                    checked: currentMode == ThemeMode.system,
                    onChanged: (_) => onModeChanged(ThemeMode.system),
                  ),
                  const SizedBox(height: 10),
                  RadioButton(
                    content: const Text('浅色模式'),
                    checked: currentMode == ThemeMode.light,
                    onChanged: (_) => onModeChanged(ThemeMode.light),
                  ),
                  const SizedBox(height: 10),
                  RadioButton(
                    content: const Text('深色模式'),
                    checked: currentMode == ThemeMode.dark,
                    onChanged: (_) => onModeChanged(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
