import 'package:fluent_ui/fluent_ui.dart';

class AutoUpdateWidget extends StatelessWidget {
  final bool checked;
  final void Function(bool) onChanged;

  const AutoUpdateWidget({
    super.key,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Card(
        borderRadius: const BorderRadiusGeometry.all(Radius.circular(5.0)),
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 6, top: 5, bottom: 5),
            child: Row(
              children: [
                const Icon(
                  FluentIcons.update_restore,
                  size: 14,
                ),
                const SizedBox(width: 17),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("自动检查更新"),
                    Text(
                      "将在每次启动时自动检测是否有可用更新，若检测到新版本，将弹出对话框进行提醒。（部分地区需配置网络代理）",
                      style: TextStyle(
                        color: FluentTheme.of(context)
                            .resources
                            .textFillColorSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ToggleSwitch(
                  checked: checked,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
