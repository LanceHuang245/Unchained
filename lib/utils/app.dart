import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/app_constant.dart';

String? latestVersionTag;
String? latestReleaseBody;

Future<bool> checkUpdate() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final rawProxy = prefs.getString('proxy_addr') ?? '';
    String proxyAddr = rawProxy;
    if (proxyAddr.startsWith('http://')) {
      proxyAddr = proxyAddr.replaceFirst('http://', '');
    } else if (proxyAddr.startsWith('https://')) {
      proxyAddr = proxyAddr.replaceFirst('https://', '');
    }

    final dio = Dio();

    if (proxyAddr.isNotEmpty) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.findProxy = (Uri uri) {
          return "PROXY $proxyAddr";
        };

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    const url =
        'https://api.github.com/repos/ClaretWheel1481/Unchained/releases/latest';
    final response = await dio.get(url);

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final Map<String, dynamic> jsonMap =
          response.data as Map<String, dynamic>;

      String rawTagName = (jsonMap['tag_name'] as String?) ?? '';
      final String rawBody = (jsonMap['body'] as String?) ?? '';

      if (rawTagName.isEmpty) {
        debugPrint("版本号解析失败。");
        return false;
      }

      final String parsedLatestTag =
          rawTagName.startsWith('v') ? rawTagName.substring(1) : rawTagName;

      latestVersionTag = parsedLatestTag;
      latestReleaseBody = rawBody;

      const String localVersion = AppConstant.appVersion;

      int compareVersionStrings(String v1, String v2) {
        final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        final len =
            (parts1.length > parts2.length) ? parts1.length : parts2.length;
        for (int i = 0; i < len; i++) {
          final num1 = (i < parts1.length) ? parts1[i] : 0;
          final num2 = (i < parts2.length) ? parts2[i] : 0;
          if (num1 != num2) {
            return num1 - num2;
          }
        }
        debugPrint("已经是最新版本。");
        return 0;
      }

      final int cmp = compareVersionStrings(parsedLatestTag, localVersion);
      debugPrint("当前版本：$localVersion, 最新版本：$parsedLatestTag");
      return cmp > 0;
    } else {
      debugPrint("更新请求失败。");
      return false;
    }
  } catch (e) {
    debugPrint("更新请求失败：$e");
    return false;
  }
}
