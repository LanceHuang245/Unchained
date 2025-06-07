import 'package:fluent_ui/fluent_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/utils/app_updater.dart';
import 'package:unchained/utils/theme_color.dart';
import 'package:unchained/widgets/navigation.dart';
import 'package:unchained/widgets/notification.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

late final ValueNotifier<Color> accentColorNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode') ?? 'system';
  themeModeNotifier.value = ThemeMode.values.firstWhere(
    (m) => m.name == saved,
    orElse: () => ThemeMode.system,
  );

  await initAccentColor();

  final autoUpdateChecked = prefs.getBool('auto_update_checked') ?? true;

  runApp(MyApp(shouldCheckUpdate: autoUpdateChecked));

  // 启动时设置窗口大小
  doWhenWindowReady(() {
    appWindow.minSize = const Size(1080, 620);
    appWindow.size = const Size(1080, 620);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatefulWidget {
  final bool shouldCheckUpdate;

  const MyApp({super.key, required this.shouldCheckUpdate});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.shouldCheckUpdate && mounted) {
        debugPrint("检查更新中...");
        final update = await checkUpdate();
        if (update && mounted) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            showUpdateDialog(
              context,
              title: latestVersionTag ?? '',
              subtitle: latestReleaseBody ?? '获取更新信息失败',
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) {
            return FluentApp(
              title: AppConstant.appName,
              navigatorKey: navigatorKey,
              themeMode: mode,
              theme: FluentThemeData(
                brightness: Brightness.light,
                accentColor: accentColor.toAccentColor(),
              ),
              darkTheme: FluentThemeData(
                brightness: Brightness.dark,
                accentColor: accentColor.toAccentColor(),
              ),
              home: const NavigationWidget(),
            );
          },
        );
      },
    );
  }
}
