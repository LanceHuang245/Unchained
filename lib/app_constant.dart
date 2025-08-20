import 'package:flutter/foundation.dart';

class AppConstant {
  static const String appName = 'Unchained';

  static const String appVersion = '1.3.2';

  static const String appRepoUrl = "https://github.com/LanceHuang245/Unchained";

  static const String ratholeRepoUrl = "https://github.com/rathole-org/rathole";

  static String assetsPath =
      kReleaseMode ? "data/flutter_assets/assets/" : "assets/";
}
