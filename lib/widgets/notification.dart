import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/main.dart';
import 'package:unchained/utils/app_updater.dart';
import 'package:url_launcher/url_launcher.dart';

enum NotificationType { success, warning, error, info }

void showBottomNotification(String content, NotificationType type) {
  // 1. 从 GlobalKey 获取当前有效的 BuildContext 和 ScaffoldMessengerState
  final scaffoldMessenger = scaffoldMessengerKey.currentState;
  final context = scaffoldMessengerKey.currentContext;

  // 2. 检查它们是否存在，以防万一
  if (scaffoldMessenger == null || context == null) {
    debugPrint("ScaffoldMessenger not available.");
    return;
  }
  final theme = Theme.of(context);
  Color backgroundColor;
  IconData iconData;

  switch (type) {
    case NotificationType.success:
      backgroundColor = theme.colorScheme.primaryContainer;
      iconData = Icons.check_circle_outline;
      break;
    case NotificationType.warning:
      backgroundColor = theme.colorScheme.secondaryContainer;
      iconData = Icons.warning_amber_outlined;
      break;
    case NotificationType.error:
      backgroundColor = theme.colorScheme.errorContainer;
      iconData = Icons.error_outline;
      break;
    case NotificationType.info:
      backgroundColor = theme.colorScheme.secondaryContainer;
      iconData = Icons.info_outline;
      break;
  }

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(iconData, color: theme.colorScheme.onSurface),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      showCloseIcon: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void showUpdateDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("发现新版本 $title"),
      content: SizedBox(
        width: MediaQuery.of(context).size.height * 0.7,
        height: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "当前版本：${AppConstant.appVersion}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Markdown(data: subtitle ?? "没有更新日志。"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('稍后再说'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('立即更新'),
          onPressed: () {
            Navigator.pop(context);
            tryAutoUpdate();
          },
        ),
      ],
    ),
  );
}

// 更新进度对话框
void showUpdatingDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AlertDialog(
      title: Text("正在更新..."),
      content: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text("请稍候"),
          ],
        ),
      ),
    ),
  );
}

Future<void> loadURL(String url) async {
  await launchUrl(Uri.parse(url));
}
