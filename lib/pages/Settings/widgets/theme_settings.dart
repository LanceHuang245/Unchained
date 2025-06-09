import 'package:fluent_ui/fluent_ui.dart';

class ThemeSettingsWidget extends StatelessWidget {
  final ThemeMode currentMode;
  final Future<void> Function(ThemeMode) onModeChanged;
  final Color currentAccentColor;
  final Future<void> Function(Color) onAccentColorChanged;

  const ThemeSettingsWidget({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    required this.currentAccentColor,
    required this.onAccentColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Expander(
        leading: const Icon(FluentIcons.light),
        header: Padding(
          padding: const EdgeInsets.only(
            left: 5,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("主题设置"),
              Text(
                "允许用户根据喜好进行主题自定义。",
                style: TextStyle(
                  color: FluentTheme.of(
                    context,
                  ).resources.textFillColorSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '选取主题颜色',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Button(
                      onPressed: () {
                        onAccentColorChanged(Colors.blue);
                      },
                      child: const Text("恢复默认"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ColorPicker(
                  color: currentAccentColor,
                  onChanged: (color) {
                    onAccentColorChanged(color);
                  },
                  colorSpectrumShape: ColorSpectrumShape.box,
                  isMoreButtonVisible: true,
                  isColorSliderVisible: true,
                  isColorChannelTextInputVisible: true,
                  isHexInputVisible: true,
                  isAlphaEnabled: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
