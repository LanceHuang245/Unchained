import 'package:flutter/material.dart';
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
    setState(() {
      _checking = true;
    });
    try {
      final updateAvailable = await checkUpdate();
      if (!mounted) return;

      if (updateAvailable) {
        showUpdateDialog(
          context,
          title: latestVersionTag ?? '',
          subtitle: latestReleaseBody ?? '获取更新信息失败',
        );
      } else {
        showBottomNotification(context, "已是最新版本", NotificationType.success);
      }
    } catch (e) {
      debugPrint("检查更新失败：$e");
      showBottomNotification(
        context,
        "检查更新时发生错误，请检查网络或权限。",
        NotificationType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.system_update_alt),
        title: const Text("检查更新"),
        subtitle: const Text("手动检查是否有可用的新版本。"),
        trailing: SizedBox(
          width: 90,
          child: _checking
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                )
              : FilledButton(
                  onPressed: _onCheckPressed,
                  child: const Text("检查"),
                ),
        ),
      ),
    );
  }
}
