import 'package:fluent_ui/fluent_ui.dart';
import 'package:unchained/app_constant.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  Future<void> _loadURL(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Expander(
        contentPadding: EdgeInsets.all(0),
        leading: Image.asset("assets/app_icon.ico", width: 20, height: 20),
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
              const Text(AppConstant.appName),
              Text(
                "由 ClaretWheel1481 发布",
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
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 5, left: 55),
              child: Text("链接"),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 45, bottom: 10),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: HyperlinkButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        _loadURL(
                          'https://github.com/yujqiao/rathole/blob/main/README-zh.md',
                        );
                      },
                      child: const Text("Rathole使用帮助"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: double.infinity, child: Divider()),
            const Padding(
              padding: EdgeInsets.only(top: 15, bottom: 5, left: 55),
              child: Text("开放源代码库"),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 45, bottom: 10),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: HyperlinkButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        _loadURL('https://github.com/rapiz1/rathole');
                      },
                      child: const Text("Rathole"),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 25, bottom: 10),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: HyperlinkButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        _loadURL(
                          'https://github.com/ClaretWheel1481/Unchained',
                        );
                      },
                      child: const Text(AppConstant.appName),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          "版本 ${AppConstant.appVersion}",
          style: TextStyle(
            color: FluentTheme.of(context).resources.textFillColorSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
