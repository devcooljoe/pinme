import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminders();
  Future<Reminder?> getReminderById(String id);
  Future<void> saveReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> updateReminder(Reminder reminder);
  Stream<List<Reminder>> watchReminders();
}