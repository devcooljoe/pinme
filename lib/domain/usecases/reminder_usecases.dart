import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

class GetAllRemindersUseCase {
  final ReminderRepository repository;

  GetAllRemindersUseCase(this.repository);

  Future<List<Reminder>> call() => repository.getAllReminders();
}

class SaveReminderUseCase {
  final ReminderRepository repository;

  SaveReminderUseCase(this.repository);

  Future<void> call(Reminder reminder) => repository.saveReminder(reminder);
}

class DeleteReminderUseCase {
  final ReminderRepository repository;

  DeleteReminderUseCase(this.repository);

  Future<void> call(String id) => repository.deleteReminder(id);
}

class UpdateReminderUseCase {
  final ReminderRepository repository;

  UpdateReminderUseCase(this.repository);

  Future<void> call(Reminder reminder) => repository.updateReminder(reminder);
}

class WatchRemindersUseCase {
  final ReminderRepository repository;

  WatchRemindersUseCase(this.repository);

  Stream<List<Reminder>> call() => repository.watchReminders();
}