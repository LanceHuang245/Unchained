import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

void showContentDialog(BuildContext context, String title, content) async {
  await showDialog(
    context: context,
    builder: (context) => ContentDialog(
      title: Text(title),
      content: Text(
        content,
      ),
      actions: [
        FilledButton(
          child: const Text('好'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

// 更新提示对话框
void showUpdateDialog(BuildContext context,
    {required String title, subtitle}) async {
  await showDialog(
    context: context,
    builder: (context) => ContentDialog(
      title: Text("检查到新版本$title"),
      content: SizedBox(
        height: 300,
        width: 400,
        child: Markdown(
          data: subtitle,
        ),
      ),
      actions: [
        Button(
          child: const Text('稍后再说'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('前往下载'),
          onPressed: () {
            Navigator.pop(context);
            loadURL('https://github.com/ClaretWheel1481/Unchained/releases');
          },
        ),
      ],
    ),
  );
}

Future loadURL(String url) async {
  await launchUrl(Uri.parse(url));
}
