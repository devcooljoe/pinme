import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/reminder_usecases.dart';
import '../../infrastructure/services/geofence_service.dart';

class ReminderNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final GetAllRemindersUseCase _getAllRemindersUseCase;
  final SaveReminderUseCase _saveReminderUseCase;
  final DeleteReminderUseCase _deleteReminderUseCase;
  final UpdateReminderUseCase _updateReminderUseCase;

  ReminderNotifier(
    this._getAllRemindersUseCase,
    this._saveReminderUseCase,
    this._deleteReminderUseCase,
    this._updateReminderUseCase,
  ) : super(const AsyncValue.loading()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    try {
      state = const AsyncValue.loading();
      final reminders = await _getAllRemindersUseCase();
      state = AsyncValue.data(reminders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createReminder({
    required String title,
    required String notes,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required TriggerType triggerType,
    int? dwellMinutes,
    required String placeName,
    required String address,
    int cooldownMinutes = 120, // 2 hours default
  }) async {
    try {
      final reminder = Reminder(
        id: const Uuid().v4(),
        title: title,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        triggerType: triggerType,
        dwellMinutes: dwellMinutes,
        enabled: true,
        createdAt: DateTime.now(),
        cooldownMinutes: cooldownMinutes,
        placeName: placeName,
        address: address,
      );

      await _saveReminderUseCase(reminder);
      await _updateGeofences();
      await loadReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _updateReminderUseCase(reminder);
      await _updateGeofences();
      await loadReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _deleteReminderUseCase(id);
      await _updateGeofences();
      await loadReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleReminder(String id) async {
    final currentState = state;
    if (currentState is AsyncData<List<Reminder>>) {
      final reminder = currentState.value.firstWhere((r) => r.id == id);
      final updatedReminder = reminder.copyWith(enabled: !reminder.enabled);
      await updateReminder(updatedReminder);
    }
  }

  Future<void> _updateGeofences() async {
    final currentState = state;
    if (currentState is AsyncData<List<Reminder>>) {
      await PinMeGeofenceService.registerGeofences(currentState.value);
    }
  }

  List<Reminder> getEnabledReminders() {
    final currentState = state;
    if (currentState is AsyncData<List<Reminder>>) {
      return currentState.value.where((r) => r.enabled).toList();
    }
    return [];
  }

  List<Reminder> getNearestReminders(double userLat, double userLon, int limit) {
    final enabled = getEnabledReminders();
    enabled.sort((a, b) {
      final distanceA = PinMeGeofenceService.calculateDistance(
        userLat, userLon, a.latitude, a.longitude,
      );
      final distanceB = PinMeGeofenceService.calculateDistance(
        userLat, userLon, b.latitude, b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    return enabled.take(limit).toList();
  }
}

final reminderNotifierProvider = 
    StateNotifierProvider<ReminderNotifier, AsyncValue<List<Reminder>>>((ref) {
  return ReminderNotifier(
    ref.read(getAllRemindersUseCaseProvider),
    ref.read(saveReminderUseCaseProvider),
    ref.read(deleteReminderUseCaseProvider),
    ref.read(updateReminderUseCaseProvider),
  );
});

// Import the providers
import '../providers/reminder_providers.dart';