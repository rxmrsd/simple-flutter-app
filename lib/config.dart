import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._(this._remoteConfig);

  static Future<RemoteConfigService> create() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    // デフォルト値を設定
    await remoteConfig.setDefaults({
      'env': 'environment',
    });

    return RemoteConfigService._(remoteConfig);
  }

  // Remote Config から値を取得
  String get envName {
    return _remoteConfig.getString('env');
  }

  // データを取得して適用
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Failed to fetch remote config: $e');
    }
  }
}