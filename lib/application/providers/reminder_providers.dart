import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/reminder_usecases.dart';
import '../../infrastructure/repositories/hive_reminder_repository.dart';

// Repository Provider
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return HiveReminderRepository();
});

// Use Case Providers
final getAllRemindersUseCaseProvider = Provider<GetAllRemindersUseCase>((ref) {
  return GetAllRemindersUseCase(ref.read(reminderRepositoryProvider));
});

final saveReminderUseCaseProvider = Provider<SaveReminderUseCase>((ref) {
  return SaveReminderUseCase(ref.read(reminderRepositoryProvider));
});

final deleteReminderUseCaseProvider = Provider<DeleteReminderUseCase>((ref) {
  return DeleteReminderUseCase(ref.read(reminderRepositoryProvider));
});

final updateReminderUseCaseProvider = Provider<UpdateReminderUseCase>((ref) {
  return UpdateReminderUseCase(ref.read(reminderRepositoryProvider));
});

final watchRemindersUseCaseProvider = Provider<WatchRemindersUseCase>((ref) {
  return WatchRemindersUseCase(ref.read(reminderRepositoryProvider));
});

// State Providers
final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.read(watchRemindersUseCaseProvider).call();
});

final selectedReminderProvider = StateProvider<Reminder?>((ref) => null);