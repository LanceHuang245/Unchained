import 'package:flutter/material.dart';

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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.update),
        title: const Text("自动检查更新"),
        subtitle: const Text("在每次启动时自动检查可用更新（部分地区需配置网络代理）"),
        trailing: Switch(value: checked, onChanged: onChanged),
      ),
    );
  }
}
