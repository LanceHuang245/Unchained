import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/utils/app_updater.dart';
import 'package:url_launcher/url_launcher.dart';

void showBottomNotification(
  BuildContext context,
  String title,
  content,
  InfoBarSeverity serverity,
) async {
  await displayInfoBar(
    context,
    builder: (context, close) => InfoBar(
      title: Text(title),
      content: Text(content),
      action: IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
      severity: serverity,
    ),
  );
}

// 更新提示对话框
void showUpdateDialog(
  BuildContext context, {
  required String title,
  subtitle,
}) async {
  await showDialog(
    context: context,
    builder: (context) => ContentDialog(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("检查到新版本$title"),
          Text(
            "当前版本：${AppConstant.appVersion}",
            style: TextStyle(
              color: FluentTheme.of(context).resources.textFillColorSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
      content: SizedBox(
        height: 300,
        width: 400,
        child: Markdown(data: subtitle),
      ),
      actions: [
        Button(
          child: const Text('稍后再说'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('立即更新'),
          onPressed: () {
            Navigator.pop(context);
            tryAutoUpdate(context);
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
    builder: (context) => const ContentDialog(
      title: Text("更新"),
      content: SizedBox(child: ProgressBar()),
      actions: null,
    ),
  );
}

Future loadURL(String url) async {
  await launchUrl(Uri.parse(url));
}
