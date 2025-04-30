import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'dart:convert';
import 'package:toml/toml.dart';
import 'package:unchained/utils/client.dart';
import 'package:unchained/widgets/notification.dart';
import 'package:unchained/widgets/terminal.dart';

class ServiceConfig {
  final TextEditingController nameController;
  final TextEditingController tokenController;
  final TextEditingController localAddrController;
  final TextEditingController retryIntervalController;
  bool nodelay;
  String type;

  ServiceConfig({
    String name = '',
    String token = '',
    String localAddr = '',
    String retryInterval = '',
    this.type = 'tcp',
    this.nodelay = true,
  })  : nameController = TextEditingController(text: name),
        tokenController = TextEditingController(text: token),
        localAddrController = TextEditingController(text: localAddr),
        retryIntervalController = TextEditingController(text: retryInterval);

  Map<String, dynamic> toMap() => {
        'token': tokenController.text,
        'local_addr': localAddrController.text,
        'type': type,
        'nodelay': nodelay,
        'retry_interval': int.tryParse(retryIntervalController.text),
      };
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final TextEditingController remoteAddrController = TextEditingController();
  final TextEditingController terminalController = TextEditingController();

  List<ServiceConfig> services = [];
  bool terminalVisible = false;
  bool processing = false;
  Process? _process;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _readFile();
  }

  Future<void> _readFile() async {
    final file = File('${Path}client.toml');
    if (!await file.exists()) return;

    final content = await file.readAsString();
    final tomlDocument = TomlDocument.parse(content);
    final tomlMap = tomlDocument.toMap();

    final client = (tomlMap['client'] ?? {}) as Map<String, dynamic>;
    remoteAddrController.text = client['remote_addr'] ?? '';

    final rawServices = client['services'];
    if (rawServices is Map<String, dynamic>) {
      services = rawServices.entries.map((e) {
        final m = e.value as Map<String, dynamic>;
        return ServiceConfig(
          name: e.key,
          token: m['token'] ?? '',
          localAddr: m['local_addr'] ?? '',
          type: m['type'] ?? 'tcp',
          nodelay: m['nodelay'] ?? false,
          retryInterval: (m['retry_interval']?.toString() ?? '1'),
        );
      }).toList();
    } else {
      services = [];
    }

    setState(() {});
  }

  void runCommand(String command) async {
    setState(() {
      terminalController.text = '';
    });

    try {
      _process = await Process.start(
        'cmd',
        ['/c', command],
        workingDirectory: '${Path}',
      );
      _process!.stdout.transform(utf8.decoder).listen((data) {
        setState(() {
          terminalController.text += data;
        });
      });
      _process!.stderr.transform(utf8.decoder).listen((data) {
        setState(() {
          terminalController.text += data;
        });
      });
      await _process!.exitCode;
    } catch (e) {
      setState(() {
        terminalController.text += 'Error running command: $e';
      });
    }
  }

  void _addService() {
    setState(() {
      services.add(ServiceConfig());
    });
  }

  void _removeService(int index) {
    setState(() {
      services.removeAt(index);
    });
  }

  bool _saveConfig() {
    for (var s in services) {
      if (s.nameController.text.isEmpty ||
          s.tokenController.text.isEmpty ||
          s.localAddrController.text.isEmpty) {
        return false;
      }
    }
    final file = File('${Path}client.toml');
    final sb = StringBuffer();
    sb.writeln('# client.toml');
    sb.writeln('[client]');
    sb.writeln('remote_addr = "${remoteAddrController.text}"');
    for (var s in services) {
      final name = s.nameController.text;
      sb.writeln('\n[client.services.$name]');
      final m = s.toMap();
      sb.writeln('token = "${m['token']}"');
      sb.writeln('local_addr = "${m['local_addr']}"');
      sb.writeln('type = "${m['type']}"');
      sb.writeln('nodelay = ${m['nodelay']}');
      sb.writeln('retry_interval = ${m['retry_interval']}');
    }
    file.writeAsStringSync(sb.toString());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('客户端配置', style: FluentTheme.of(context).typography.title),
      ),
      content: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                InfoLabel(
                  label: '服务端地址',
                  child: TextBox(controller: remoteAddrController),
                ),
                const SizedBox(height: 10),
                ...services.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('服务 ${i + 1}',
                                style: FluentTheme.of(context)
                                    .typography
                                    .subtitle),
                            IconButton(
                              icon: const Icon(FluentIcons.delete),
                              onPressed: () => _removeService(i),
                            ),
                          ],
                        ),
                        TextBox(
                          placeholder: '服务名称',
                          controller: s.nameController,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextBox(
                                placeholder: '本地服务地址与端口',
                                controller: s.localAddrController,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ComboBox<String>(
                              value: s.type,
                              items: ['tcp', 'udp']
                                  .map((t) =>
                                      ComboBoxItem(value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) => setState(() => s.type = v!),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextBox(
                          placeholder: 'Token',
                          controller: s.tokenController,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                ToggleSwitch(
                                  checked: s.nodelay,
                                  onChanged: (v) =>
                                      setState(() => s.nodelay = v),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 5,
                                  ),
                                  child: Tooltip(
                                    message: '通过降低部分带宽来优化延迟，关闭后带宽提高但延迟增加。',
                                    child: Text('延迟优化'),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextBox(
                                placeholder: '重试间隔',
                                controller: s.retryIntervalController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: _addService,
                    child: const Text('新增服务'),
                  ),
                ),
                const SizedBox(height: 20),
                if (terminalVisible) ...[
                  const SizedBox(height: 20),
                  Terminal(controller: terminalController, visible: true),
                ],
              ],
            ),
          ),
          Positioned(
              right: 24,
              bottom: 24,
              child: FilledButton(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(processing ? FluentIcons.stop : FluentIcons.play),
                ),
                onPressed: () {
                  if (processing) {
                    stopCommand();
                    setState(() {
                      processing = false;
                      terminalVisible = false;
                    });
                    showContentDialog(context, '通知', '已停止');
                  } else {
                    if (!_saveConfig()) {
                      showContentDialog(context, '错误', '请检查输入');
                      return;
                    }
                    setState(() {
                      processing = true;
                      terminalVisible = true;
                    });
                    runCommand('rathole.exe client.toml');
                    showContentDialog(context, '通知', '请查看日志');
                  }
                },
              )),
        ],
      ),
    );
  }
}
