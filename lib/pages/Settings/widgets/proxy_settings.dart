import 'package:fluent_ui/fluent_ui.dart';

class ProxySettingsWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const ProxySettingsWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Expander(
        leading: const Icon(FluentIcons.internet_sharing),
        header: Padding(
          padding: const EdgeInsets.only(
            left: 6,
            right: 20,
            top: 15,
            bottom: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("代理设置"),
              Text(
                "用于Unchained的网络代理，通常用于检查、下载更新功能，不影响中继转发功能。",
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
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InfoLabel(
                label: '代理服务器地址',
                child: TextBox(
                  placeholder: "127.0.0.1:7890",
                  controller: controller,
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
