import 'package:fluent_ui/fluent_ui.dart';

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
