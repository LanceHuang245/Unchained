import 'package:flutter/material.dart';

class ProxySettingsWidget extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;

  const ProxySettingsWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ProxySettingsWidget> createState() => _ProxySettingsWidgetState();
}

class _ProxySettingsWidgetState extends State<ProxySettingsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.lan_outlined),
            title: const Text("代理设置"),
            subtitle: const Text("用于检查、下载更新等功能的网络代理，不影响中继转发"),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 150),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                decoration: const InputDecoration(
                  labelText: '代理服务器地址',
                  hintText: '例如：127.0.0.1:7890',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            secondChild: Container(),
          ),
        ],
      ),
    );
  }
}
