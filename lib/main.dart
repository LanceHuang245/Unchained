import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/utils/app_updater.dart';
import 'package:unchained/utils/theme_color.dart';
import 'package:unchained/widgets/navigation.dart';
import 'package:unchained/widgets/notification.dart';
import 'package:window_manager/window_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
late final ValueNotifier<Color> accentColorNotifier;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1080, 620),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('theme_mode') ?? 'system';
  themeModeNotifier.value = ThemeMode.values.firstWhere(
    (m) => m.name == saved,
    orElse: () => ThemeMode.system,
  );

  await initAccentColor();

  final autoUpdateChecked = prefs.getBool('auto_update_checked') ?? true;

  runApp(MyApp(shouldCheckUpdate: autoUpdateChecked));
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
        try {
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
        } catch (e) {
          debugPrint("检查更新时发生错误：$e");
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
            return MaterialApp(
              title: AppConstant.appName,
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              themeMode: mode,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorSchemeSeed: accentColor,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: accentColor,
              ),
              debugShowCheckedModeBanner: false,
              home: const NavigationWidget(),
            );
          },
        );
      },
    );
  }
}
