import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/utils/client.dart';
import 'package:unchained/widgets/navigation.dart';
import 'package:unchained/widgets/notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // 检查Toml文件是否存在，没有则初始化
  await initClientToml();

  // 检查是否第一次启动
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

  runApp(const MyApp());

  // 启动时设置窗口大小
  doWhenWindowReady(() {
    appWindow.minSize = const Size(1080, 620);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });

  if (isFirstLaunch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showContentDialog(
        navigatorKey.currentState!.overlay!.context,
        '通知',
        '请关闭Windows Defender或其他杀毒软件，以免Rathole.exe被误杀导致程序错误。若Rathole.exe已经被删除，请关闭杀毒软件并重新安装该程序。',
      );
    });
    await prefs.setBool('is_first_launch', false);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      navigatorKey: navigatorKey,
      theme: FluentThemeData(
          brightness: Brightness.light,
          fontFamily: "MSYH",
          accentColor: Colors.blue),
      home: const NavigationWidget(),
    );
  }
}
