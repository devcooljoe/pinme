import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/notifiers/reminder_notifier.dart';
import '../../domain/entities/reminder.dart';
import '../../infrastructure/services/location_service.dart';
import '../widgets/permission_banner.dart';
import '../widgets/reminder_list_item.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderNotifierProvider);
    final currentLocation = useState<Position?>(null);

    useEffect(() {
      _getCurrentLocation(currentLocation);
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PinMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.go('/map'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const PermissionBanner(),
          Expanded(
            child: remindersAsync.when(
              data:
                  (reminders) => _buildRemindersList(
                    context,
                    ref,
                    reminders,
                    currentLocation.value,
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  ref
                                      .read(reminderNotifierProvider.notifier)
                                      .loadReminders(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/reminder/new'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemindersList(
    BuildContext context,
    WidgetRef ref,
    List<Reminder> reminders,
    Position? currentLocation,
  ) {
    if (reminders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No reminders yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to create your first location reminder',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Sort reminders by distance if location is available
    final sortedReminders = List<Reminder>.from(reminders);
    if (currentLocation != null) {
      sortedReminders.sort((a, b) {
        final distanceA = LocationService.calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = LocationService.calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });
    }

    return ListView.builder(
      itemCount: sortedReminders.length,
      itemBuilder: (context, index) {
        final reminder = sortedReminders[index];
        return Slidable(
          key: ValueKey(reminder.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _editReminder(context, reminder),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (_) => _deleteReminder(context, ref, reminder),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ReminderListItem(
            reminder: reminder,
            currentLocation: currentLocation,
            onTap: () => _editReminder(context, reminder),
            onToggle:
                () => ref
                    .read(reminderNotifierProvider.notifier)
                    .toggleReminder(reminder.id),
          ),
        );
      },
    );
  }

  void _editReminder(BuildContext context, Reminder reminder) {
    context.go('/reminder/edit/${reminder.id}', extra: reminder);
  }

  void _deleteReminder(BuildContext context, WidgetRef ref, Reminder reminder) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reminder'),
            content: Text(
              'Are you sure you want to delete "${reminder.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(reminderNotifierProvider.notifier)
                      .deleteReminder(reminder.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _getCurrentLocation(ValueNotifier<Position?> currentLocation) async {
    try {
      final position = await LocationService.getCurrentPosition();
      currentLocation.value = position;
    } catch (e) {
      // Handle error silently
    }
  }
}
