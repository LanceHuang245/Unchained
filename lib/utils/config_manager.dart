import 'dart:io';
import 'package:toml/toml.dart';
import 'package:unchained/classes/service_config.dart';
import 'package:unchained/utils/client.dart';

class ConfigManager {
  static Future<Map<String, dynamic>> readRatholeConfig() async {
    final file = File('${Path}client.toml');
    if (!await file.exists()) {
      return {'remoteAddr': '', 'services': <RatholeServiceConfig>[]};
    }

    final content = await file.readAsString();
    final tomlDocument = TomlDocument.parse(content);
    final tomlMap = tomlDocument.toMap();

    final client = (tomlMap['client'] ?? {}) as Map<String, dynamic>;
    final remoteAddr = client['remote_addr'] ?? '';

    final rawServices = client['services'];
    List<RatholeServiceConfig> services = [];

    if (rawServices is Map<String, dynamic>) {
      services = rawServices.entries.map((e) {
        final m = e.value as Map<String, dynamic>;
        return RatholeServiceConfig(
          name: e.key,
          token: m['token'] ?? '',
          localAddr: m['local_addr'] ?? '',
          type: m['type'] ?? 'tcp',
          nodelay: m['nodelay'] ?? false,
          retryInterval: (m['retry_interval']?.toString() ?? '1'),
        );
      }).toList();
    }

    return {'remoteAddr': remoteAddr, 'services': services};
  }

  static bool saveRatholeConfig(
      String remoteAddr, List<RatholeServiceConfig> services) {
    // 验证所有服务配置是否完整
    for (var s in services) {
      if (s.nameController.text.isEmpty ||
          s.tokenController.text.isEmpty ||
          s.localAddrController.text.isEmpty ||
          s.retryIntervalController.text.isEmpty) {
        return false;
      }
    }

    final file = File('${Path}client.toml');
    final sb = StringBuffer();
    sb.writeln('# client.toml');
    sb.writeln('[client]');
    sb.writeln('remote_addr = "$remoteAddr"');

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
}
