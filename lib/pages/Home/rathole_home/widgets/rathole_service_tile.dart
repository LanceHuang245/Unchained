// pages/home/rathole_home/widgets/rathole_service_tile.dart

import 'package:flutter/material.dart';
import 'package:unchained/classes/service_config.dart';

class RatholeServiceTile extends StatefulWidget {
  final RatholeServiceConfig service;
  final int index;
  final Animation<double> animation;
  final bool processing;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const RatholeServiceTile({
    super.key,
    required this.service,
    required this.index,
    required this.animation,
    required this.processing,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<RatholeServiceTile> createState() => _RatholeServiceTileState();
}

class _RatholeServiceTileState extends State<RatholeServiceTile> {
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服务'),
        content: const Text('确定要删除该服务吗？此操作无法撤销。'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FilledButton(
            child: const Text('删除'),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.processing;

    return SizeTransition(
      sizeFactor: widget.animation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '服务 ${widget.index + 1}',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: "删除服务",
                    onPressed: isEnabled ? _showDeleteConfirmationDialog : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: isEnabled,
                controller: widget.service.nameController,
                onChanged: (_) => widget.onUpdate(),
                decoration: const InputDecoration(
                  labelText: '服务名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: isEnabled,
                      controller: widget.service.localAddrController,
                      onChanged: (_) => widget.onUpdate(),
                      decoration: const InputDecoration(
                        labelText: '本地服务地址',
                        hintText: '例如: 127.0.0.1:8080',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 下拉菜单
                  DropdownButton<String>(
                    value: widget.service.type,
                    items: ['tcp', 'udp']
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: isEnabled
                        ? (v) {
                            setState(() => widget.service.type = v!);
                            widget.onUpdate();
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: isEnabled,
                controller: widget.service.tokenController,
                onChanged: (_) => widget.onUpdate(),
                decoration: const InputDecoration(
                  labelText: 'Token (可选)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Switch(
                    value: widget.service.nodelay,
                    onChanged: isEnabled
                        ? (v) {
                            setState(() => widget.service.nodelay = v);
                            widget.onUpdate();
                          }
                        : null,
                  ),
                  const SizedBox(width: 8),
                  const Text('延迟优化 (nodelay)'),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      enabled: isEnabled,
                      controller: widget.service.retryIntervalController,
                      onChanged: (_) => widget.onUpdate(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '重试间隔 (秒)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
