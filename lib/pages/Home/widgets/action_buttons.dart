import 'package:fluent_ui/fluent_ui.dart';

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
    return Row(
      children: [
        FilledButton(
          onPressed: processing ? null : onAddService,
          child: const SizedBox(
            width: 100,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FluentIcons.add),
                SizedBox(width: 10),
                Text("新增服务")
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        FilledButton(
          onPressed: onToggleProcess,
          child: SizedBox(
            width: 100,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(processing ? FluentIcons.stop : FluentIcons.play),
                const SizedBox(width: 10),
                Text(processing ? "停止" : "运行")
              ],
            ),
          ),
        ),
      ],
    );
  }
}
