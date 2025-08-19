import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ThemeSettingsWidget extends StatefulWidget {
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
  State<ThemeSettingsWidget> createState() => _ThemeSettingsWidgetState();
}

class _ThemeSettingsWidgetState extends State<ThemeSettingsWidget> {
  bool _isExpanded = false;

  void _showColorPickerDialog(BuildContext context) {
    Color pickerColor = widget.currentAccentColor;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('选取主题颜色'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      pickerColor = color;
                    });
                    widget.onAccentColorChanged(color);
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: true,
                  labelTypes: const [],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('完成'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text("主题设置"),
            subtitle: const Text("允许用户根据喜好进行主题自定义。"),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 150),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("应用主题", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        RadioListTile<ThemeMode>(
                          title: const Text('跟随系统'),
                          value: ThemeMode.system,
                          groupValue: widget.currentMode,
                          onChanged: (v) => widget.onModeChanged(v!),
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('浅色模式'),
                          value: ThemeMode.light,
                          groupValue: widget.currentMode,
                          onChanged: (v) => widget.onModeChanged(v!),
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text('深色模式'),
                          value: ThemeMode.dark,
                          groupValue: widget.currentMode,
                          onChanged: (v) => widget.onModeChanged(v!),
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("主题颜色", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text("当前颜色:"),
                            const SizedBox(width: 16),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: widget.currentAccentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.dividerColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            FilledButton.tonal(
                              onPressed: () => _showColorPickerDialog(context),
                              child: const Text("更改颜色"),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () =>
                                  widget.onAccentColorChanged(Colors.blue),
                              child: const Text("恢复默认"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            secondChild: Container(),
          ),
        ],
      ),
    );
  }
}
