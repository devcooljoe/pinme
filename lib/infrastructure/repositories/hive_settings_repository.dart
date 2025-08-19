import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_model.dart';

class HiveSettingsRepository implements SettingsRepository {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'app_settings';
  late Box<SettingsModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SettingsModel>(_boxName);
  }

  @override
  Future<AppSettings> getSettings() async {
    final model = _box.get(_settingsKey);
    return model?.toEntity() ?? AppSettings.defaultSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final model = SettingsModel.fromEntity(settings);
    await _box.put(_settingsKey, model);
  }

  @override
  Stream<AppSettings> watchSettings() {
    return _box.watch(key: _settingsKey).map((_) => getSettings()).asyncMap((future) => future);
  }
}