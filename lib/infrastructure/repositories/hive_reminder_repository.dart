import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_model.dart';

class HiveReminderRepository implements ReminderRepository {
  static const String _boxName = 'reminders';
  late Box<ReminderModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ReminderModel>(_boxName);
  }

  @override
  Future<List<Reminder>> getAllReminders() async {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    final model = _box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _box.put(reminder.id, model);
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    await saveReminder(reminder);
  }

  @override
  Stream<List<Reminder>> watchReminders() {
    return _box.watch().map((_) => getAllReminders()).asyncMap((future) => future);
  }
}