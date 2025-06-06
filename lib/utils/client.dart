import 'dart:io';

import 'package:unchained/app_constant.dart';

Future<void> initRatholeClientToml() async {
  final file = File('${AppConstant.assetsPath}client.toml');
  if (!await file.exists()) {
    await file.create(recursive: true);
    await file.writeAsString('''
# client.toml
[client]
remote_addr = ""
''');
  }
}

bool saveRatholeFile(String service, remoteAddr, token, localAddr, type,
    bool nodelay, int retryInterval) {
  try {
    final file = File('${AppConstant.assetsPath}client.toml');
    final content = '''
# client.toml
[client]
remote_addr = "$remoteAddr"

[client.services.$service]
token = "$token"
local_addr = "$localAddr"
type = "$type"
nodelay = $nodelay
retry_interval = $retryInterval
''';
    file.writeAsString(content);
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> stopRathole() async {
  await Process.start('taskkill', ['/F', '/IM', 'rathole.exe']);
}
