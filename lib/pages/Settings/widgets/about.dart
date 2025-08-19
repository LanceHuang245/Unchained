import 'package:flutter/material.dart';
import 'package:unchained/app_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  Future<void> _loadURL(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildLinkButton(String text, String url) {
      return TextButton(onPressed: () => _loadURL(url), child: Text(text));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Image.asset(
                "assets/app_icon.ico",
                width: 40,
                height: 40,
              ),
              title: const Text(AppConstant.appName),
              subtitle: const Text("由 ClaretWheel1481 发布"),
              trailing: Text(
                "版本 ${AppConstant.appVersion}",
                style: theme.textTheme.bodySmall,
              ),
            ),
            const Divider(height: 24),
            ListTile(
              title: const Text("链接"),
              subtitle: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  buildLinkButton(
                    'Rathole 使用帮助',
                    'https://github.com/yujqiao/rathole/blob/main/README-zh.md',
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("开放源代码库"),
              subtitle: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  buildLinkButton(
                    'Rathole',
                    'https://github.com/rapiz1/rathole',
                  ),
                  buildLinkButton(
                    AppConstant.appName,
                    'https://github.com/LanceHuang245/Unchained',
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
