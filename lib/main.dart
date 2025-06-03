import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/utils/client.dart';
import 'package:unchained/widgets/navigation.dart';
import 'package:unchained/widgets/notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 全局 ThemeMode 通知器
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 读取持久化的主题模式
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode') ?? 'system';
  themeModeNotifier.value = ThemeMode.values.firstWhere(
    (m) => m.name == saved,
    orElse: () => ThemeMode.system,
  );

  // 检查Toml文件是否存在，没有则初始化
  await initClientToml();

  // 检查是否第一次启动
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

  runApp(const MyApp());

  // 启动时设置窗口大小
  doWhenWindowReady(() {
    appWindow.minSize = const Size(1080, 620);
    appWindow.size = const Size(1080, 620);
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return FluentApp(
          title: 'Unchained',
          themeMode: mode,
          theme: FluentThemeData(
              brightness: Brightness.light,
              accentColor: Colors.blue,
              fontFamily: "msyh"),
          darkTheme: FluentThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.blue,
              fontFamily: "msyh"),
          home: const NavigationWidget(),
        );
      },
    );
  }
}
