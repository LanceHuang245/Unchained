import 'package:fluent_ui/fluent_ui.dart';
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
  final FlyoutController _deleteFlyoutController = FlyoutController();

  @override
  void dispose() {
    _deleteFlyoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).cardColor,
          border: Border.all(
            color: FluentTheme.of(context).resources.controlStrokeColorDefault,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '服务 ${widget.index + 1}',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                FlyoutTarget(
                  controller: _deleteFlyoutController,
                  child: IconButton(
                    icon: const Icon(FluentIcons.delete),
                    onPressed: widget.processing
                        ? null
                        : () {
                            _deleteFlyoutController.showFlyout(
                              autoModeConfiguration: FlyoutAutoConfiguration(
                                preferredMode: FlyoutPlacementMode.topCenter,
                              ),
                              barrierDismissible: true,
                              dismissOnPointerMoveAway: false,
                              dismissWithEsc: true,
                              builder: (context) {
                                return FlyoutContent(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '删除服务',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      const Text(
                                        '确定要删除该服务吗？此操作无法撤销。',
                                      ),
                                      const SizedBox(height: 12.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Button(
                                            child: const Text('取消'),
                                            onPressed: () {
                                              Flyout.of(context).close();
                                            },
                                          ),
                                          const SizedBox(width: 8.0),
                                          FilledButton(
                                            child: const Text('删除'),
                                            onPressed: () {
                                              Flyout.of(context).close();
                                              widget.onDelete();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            TextBox(
              enabled: !widget.processing,
              placeholder: '服务名称',
              controller: widget.service.nameController,
              onChanged: (_) => widget.onUpdate(),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: '输入你想转发的本地服务地址与端口，如：127.0.0.1:8080',
                    displayHorizontally: true,
                    useMousePosition: false,
                    child: TextBox(
                      enabled: !widget.processing,
                      placeholder: '本地服务地址与端口',
                      controller: widget.service.localAddrController,
                      onChanged: (_) => widget.onUpdate(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: '选择转发的服务类型',
                  displayHorizontally: true,
                  useMousePosition: false,
                  child: ComboBox<String>(
                    value: widget.service.type,
                    items: ['tcp', 'udp']
                        .map(
                          (t) => ComboBoxItem(value: t, child: Text(t)),
                        )
                        .toList(),
                    onChanged: widget.processing
                        ? null
                        : (v) {
                            setState(() => widget.service.type = v!);
                            widget.onUpdate();
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            TextBox(
              enabled: !widget.processing,
              placeholder: 'Token',
              controller: widget.service.tokenController,
              onChanged: (_) => widget.onUpdate(),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Row(
                  children: [
                    ToggleSwitch(
                      checked: widget.service.nodelay,
                      onChanged: widget.processing
                          ? null
                          : (v) {
                              setState(() => widget.service.nodelay = v);
                              widget.onUpdate();
                            },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Tooltip(
                        displayHorizontally: true,
                        useMousePosition: false,
                        message: '通过降低部分带宽来优化延迟，关闭后带宽提高但延迟增加',
                        child: Text('延迟优化'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Tooltip(
                    displayHorizontally: true,
                    useMousePosition: true,
                    message: '当服务端连接失败时，每隔*秒重试一次',
                    child: TextBox(
                      keyboardType: TextInputType.number,
                      enabled: !widget.processing,
                      placeholder: '重试间隔(s)',
                      controller: widget.service.retryIntervalController,
                      onChanged: (_) => widget.onUpdate(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
