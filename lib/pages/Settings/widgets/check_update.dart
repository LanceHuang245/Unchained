import 'package:fluent_ui/fluent_ui.dart';
import 'package:unchained/utils/app_updater.dart';
import 'package:unchained/widgets/notification.dart';

class CheckUpdateWidget extends StatefulWidget {
  const CheckUpdateWidget({super.key});

  @override
  CheckUpdateWidgetState createState() => CheckUpdateWidgetState();
}

class CheckUpdateWidgetState extends State<CheckUpdateWidget> {
  bool _checking = false;

  Future<void> _onCheckPressed() async {
    if (!mounted) return;
    setState(() => _checking = true);

    final updateAvailable = await checkUpdate();
    if (!mounted) return;

    if (updateAvailable) {
      showUpdateDialog(
        context,
        title: latestVersionTag ?? '',
        subtitle: latestReleaseBody ?? '获取更新信息失败',
      );
    } else {
      showBottomNotification(
        context,
        "无需更新",
        "当前已是最新版本。",
        InfoBarSeverity.success,
      );
    }

    if (!mounted) return;
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Card(
        borderRadius: const BorderRadiusGeometry.all(Radius.circular(5.0)),
        child: SizedBox(
          height: 41,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                const Icon(
                  FluentIcons.update_restore,
                  size: 15,
                ),
                const SizedBox(width: 17),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("检查更新"),
                    Text(
                      "将检查一次更新，若检测到新版本，将弹出对话框进行提醒。（部分地区需配置网络代理）",
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
                _checking
                    ? const ProgressRing()
                    : FilledButton(
                        onPressed: _onCheckPressed,
                        child: const Text("检查更新"),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
