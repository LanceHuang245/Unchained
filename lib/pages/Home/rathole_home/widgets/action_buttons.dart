// pages/home/rathole_home/widgets/action_buttons.dart

import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final bool processing;
  final VoidCallback onAddService;
  final VoidCallback onToggleProcess;

  const ActionButtons({
    super.key,
    required this.processing,
    required this.onAddService,
    required this.onToggleProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: [
        processing
            ? SizedBox(width: 0)
            : FloatingActionButton.extended(
                heroTag: 'add_service_fab',
                onPressed: onAddService,
                label: const Text("新增服务"),
                icon: const Icon(Icons.add),
              ),
        FloatingActionButton.extended(
          heroTag: 'toggle_process_fab',
          onPressed: onToggleProcess,
          label: Text(processing ? "停止" : "运行"),
          icon: Icon(processing ? Icons.stop : Icons.play_arrow),
          backgroundColor: processing
              ? Theme.of(context).colorScheme.tertiaryContainer
              : Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: processing
              ? Theme.of(context).colorScheme.onTertiaryContainer
              : Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ],
    );
  }
}
