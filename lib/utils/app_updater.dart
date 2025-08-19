import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unchained/app_constant.dart';
import 'package:unchained/classes/rathole_config_manager.dart';
import 'package:unchained/widgets/notification.dart';

String? latestVersionTag;
String? latestReleaseBody;
String? latestZipDownloadUrl;

Future<bool> checkUpdate() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final rawProxy = prefs.getString('proxy_addr') ?? '';
    String proxyAddr = rawProxy;
    if (proxyAddr.startsWith('http://')) {
      proxyAddr = proxyAddr.replaceFirst('http://', '');
    } else if (proxyAddr.startsWith('https://')) {
      proxyAddr = proxyAddr.replaceFirst('https://', '');
    } else if (proxyAddr.startsWith('socks://')) {
      proxyAddr = proxyAddr.replaceFirst('socks://', '');
    } else if (proxyAddr.startsWith('socks5://')) {
      proxyAddr = proxyAddr.replaceFirst('socks5://', '');
    }

    final dio = Dio();
    if (proxyAddr.isNotEmpty) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
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

      final String parsedLatestTag = rawTagName.startsWith('v')
          ? rawTagName.substring(1)
          : rawTagName;

      latestVersionTag = parsedLatestTag;
      latestReleaseBody = rawBody;

      final assets = (jsonMap['assets'] as List<dynamic>?);
      if (assets == null || assets.isEmpty) {
        debugPrint("未找到任何Release版本");
        return false;
      }

      final firstAsset = assets.first as Map<String, dynamic>;
      final String downloadUrl =
          (firstAsset['browser_download_url'] as String?) ?? '';
      if (downloadUrl.isEmpty) {
        debugPrint("下载链接解析失败");
        return false;
      }
      latestZipDownloadUrl = downloadUrl;

      const String localVersion = AppConstant.appVersion;

      int compareVersionStrings(String v1, String v2) {
        final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        final len = (parts1.length > parts2.length)
            ? parts1.length
            : parts2.length;
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
    rethrow;
  }
}

Future<String?> downloadAndUnzipToTempDir() async {
  try {
    if (latestZipDownloadUrl == null || latestZipDownloadUrl!.isEmpty) {
      debugPrint("下载链接为空，无法下载");
      return null;
    }
    final prefs = await SharedPreferences.getInstance();
    final rawProxy = prefs.getString('proxy_addr') ?? '';
    String proxyAddr = rawProxy;
    if (proxyAddr.startsWith('http://')) {
      proxyAddr = proxyAddr.replaceFirst('http://', '');
    } else if (proxyAddr.startsWith('https://')) {
      proxyAddr = proxyAddr.replaceFirst('https://', '');
    } else if (proxyAddr.startsWith('socks://')) {
      proxyAddr = proxyAddr.replaceFirst('socks://', '');
    } else if (proxyAddr.startsWith('socks5://')) {
      proxyAddr = proxyAddr.replaceFirst('socks5://', '');
    }

    final dio = Dio();
    if (proxyAddr.isNotEmpty) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.findProxy = (Uri uri) {
          return "PROXY $proxyAddr";
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    final tempDir = await getTemporaryDirectory();
    final String zipFilePath = "${tempDir.path}\\update_package.zip";

    debugPrint("开始下载新版 ZIP：$latestZipDownloadUrl");
    await dio.download(
      latestZipDownloadUrl!,
      zipFilePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          final percent = (received / total * 100).toStringAsFixed(0);
          debugPrint("下载进度：$percent%");
        }
      },
    );
    debugPrint("ZIP 下载完成，路径：$zipFilePath");

    final bytes = File(zipFilePath).readAsBytesSync();
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    debugPrint("ZIP 解码完毕，共包含 ${archive.length} 个条目");

    final String updateDirPath =
        "${tempDir.path}\\update_${DateTime.now().millisecondsSinceEpoch}";
    final Directory updateDir = Directory(updateDirPath);
    if (!updateDir.existsSync()) {
      updateDir.createSync(recursive: true);
    }
    debugPrint("更新临时目录：$updateDirPath");

    for (final file in archive) {
      final String filename = file.name;
      final String outPath = "$updateDirPath\\$filename";
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File(outPath);
        outFile.parent.createSync(recursive: true);
        outFile.writeAsBytesSync(data, flush: true);
        debugPrint("解压文件到：$outPath");
      } else {
        final dirPath = outPath;
        Directory(dirPath).createSync(recursive: true);
        debugPrint("创建目录：$dirPath");
      }
    }

    debugPrint("所有文件都已解压到临时更新目录");
    return updateDirPath;
  } catch (e) {
    debugPrint("下载或解压失败：$e");
    return null;
  }
}

void launchUpdaterAndExit(String updateDirPath) async {
  final String installDir = File(Platform.resolvedExecutable).parent.path;
  final String updaterExePath = "$installDir\\Updater.exe";

  if (!File(updaterExePath).existsSync()) {
    debugPrint("找不到 Updater.exe：$updaterExePath");
    return;
  }

  try {
    Process.start(
      'cmd',
      ['/C', 'start', '', updaterExePath, updateDirPath, installDir],
      workingDirectory: installDir,
      runInShell: true,
    );
    debugPrint("已启动Updater.exe");
  } catch (e) {
    debugPrint("启动Updater.exe时出错：$e");
    return;
  }

  await RatholeConfigManager.stopRathole();
  exit(0);
}

Future<void> tryAutoUpdate(BuildContext context) async {
  if (!context.mounted) return;

  final hasUpdate = await checkUpdate();
  if (hasUpdate && latestVersionTag != null) {
    showBottomNotification(context, "正在下载并准备更新，请稍后……", NotificationType.info);

    if (!context.mounted) return;
    showUpdatingDialog(context);

    final String? updateDirPath = await downloadAndUnzipToTempDir();

    if (!context.mounted) return;
    // 关闭更新进度对话框
    Navigator.pop(context);

    if (updateDirPath == null) {
      if (!context.mounted) return;
      showBottomNotification(
        context,
        "下载或解压时发生错误，请检查网络或权限。",
        NotificationType.error,
      );
      return;
    }

    if (!context.mounted) return;
    showBottomNotification(
      context,
      "下载完成，程序即将关闭并更新。",
      NotificationType.warning,
    );

    Future.delayed(const Duration(seconds: 3), () async {
      launchUpdaterAndExit(updateDirPath);
    });
  } else {
    if (!context.mounted) return;
    showBottomNotification(context, "当前已是最新版本。", NotificationType.success);
  }
}
