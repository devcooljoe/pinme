import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/reminder.dart';
import '../../application/notifiers/reminder_notifier.dart';

class ReminderFormPage extends HookConsumerWidget {
  final Reminder? reminder;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialPlaceName;
  final String? initialAddress;

  const ReminderFormPage({
    super.key,
    this.reminder,
    this.initialLatitude,
    this.initialLongitude,
    this.initialPlaceName,
    this.initialAddress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: reminder?.title ?? '');
    final notesController = useTextEditingController(text: reminder?.notes ?? '');
    final placeNameController = useTextEditingController(
      text: reminder?.placeName ?? initialPlaceName ?? '',
    );
    final addressController = useTextEditingController(
      text: reminder?.address ?? initialAddress ?? '',
    );
    
    final triggerType = useState(reminder?.triggerType ?? TriggerType.enter);
    final radiusMeters = useState(reminder?.radiusMeters ?? 100.0);
    final dwellMinutes = useState(reminder?.dwellMinutes ?? 5);
    final cooldownMinutes = useState(reminder?.cooldownMinutes ?? 120);
    final isLoading = useState(false);

    final latitude = reminder?.latitude ?? initialLatitude;
    final longitude = reminder?.longitude ?? initialLongitude;

    return Scaffold(
      appBar: AppBar(
        title: Text(reminder != null ? 'Edit Reminder' : 'New Reminder'),
        actions: [
          TextButton(
            onPressed: isLoading.value ? null : () => _saveReminder(
              context,
              ref,
              titleController,
              notesController,
              placeNameController,
              addressController,
              triggerType.value,
              radiusMeters.value,
              dwellMinutes.value,
              cooldownMinutes.value,
              latitude,
              longitude,
              isLoading,
            ),
            child: isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Buy groceries',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional details...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Location Info
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: placeNameController,
              decoration: const InputDecoration(
                labelText: 'Place Name *',
                hintText: 'e.g., Whole Foods Market',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Street address or coordinates',
              ),
            ),
            const SizedBox(height: 24),

            // Trigger Settings
            const Text(
              'Trigger',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTriggerTypeSelector(triggerType),
            const SizedBox(height: 16),

            if (triggerType.value == TriggerType.dwell) ...[
              Text('Dwell Time: ${dwellMinutes.value} minutes'),
              Slider(
                value: dwellMinutes.value.toDouble(),
                min: 1,
                max: 60,
                divisions: 59,
                onChanged: (value) => dwellMinutes.value = value.toInt(),
              ),
              const SizedBox(height: 16),
            ],

            // Radius Settings
            const Text(
              'Geofence Radius',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Radius: ${radiusMeters.value.toInt()} meters'),
            Slider(
              value: radiusMeters.value,
              min: 50,
              max: 1000,
              divisions: 19,
              onChanged: (value) => radiusMeters.value = value,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRadiusPreset('Small\n50m', 50, radiusMeters),
                _buildRadiusPreset('Medium\n100m', 100, radiusMeters),
                _buildRadiusPreset('Large\n200m', 200, radiusMeters),
                _buildRadiusPreset('XL\n500m', 500, radiusMeters),
              ],
            ),
            const SizedBox(height: 24),

            // Cooldown Settings
            const Text(
              'Cooldown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Cooldown: ${cooldownMinutes.value} minutes'),
            const Text(
              'Prevents duplicate notifications',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Slider(
              value: cooldownMinutes.value.toDouble(),
              min: 0,
              max: 480, // 8 hours
              divisions: 16,
              onChanged: (value) => cooldownMinutes.value = value.toInt(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCooldownPreset('None', 0, cooldownMinutes),
                _buildCooldownPreset('30m', 30, cooldownMinutes),
                _buildCooldownPreset('2h', 120, cooldownMinutes),
                _buildCooldownPreset('4h', 240, cooldownMinutes),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTriggerTypeSelector(ValueNotifier<TriggerType> triggerType) {
    return Column(
      children: [
        RadioListTile<TriggerType>(
          title: const Text('On Arrive (Enter)'),
          subtitle: const Text('Trigger when entering the area'),
          value: TriggerType.enter,
          groupValue: triggerType.value,
          onChanged: (value) => triggerType.value = value!,
        ),
        RadioListTile<TriggerType>(
          title: const Text('On Leave (Exit)'),
          subtitle: const Text('Trigger when leaving the area'),
          value: TriggerType.exit,
          groupValue: triggerType.value,
          onChanged: (value) => triggerType.value = value!,
        ),
        RadioListTile<TriggerType>(
          title: const Text('While Here (Dwell)'),
          subtitle: const Text('Trigger after staying in the area'),
          value: TriggerType.dwell,
          groupValue: triggerType.value,
          onChanged: (value) => triggerType.value = value!,
        ),
      ],
    );
  }

  Widget _buildRadiusPreset(String label, double value, ValueNotifier<double> radiusMeters) {
    return ElevatedButton(
      onPressed: () => radiusMeters.value = value,
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  Widget _buildCooldownPreset(String label, int value, ValueNotifier<int> cooldownMinutes) {
    return ElevatedButton(
      onPressed: () => cooldownMinutes.value = value,
      child: Text(label),
    );
  }

  void _saveReminder(
    BuildContext context,
    WidgetRef ref,
    TextEditingController titleController,
    TextEditingController notesController,
    TextEditingController placeNameController,
    TextEditingController addressController,
    TriggerType triggerType,
    double radiusMeters,
    int dwellMinutes,
    int cooldownMinutes,
    double? latitude,
    double? longitude,
    ValueNotifier<bool> isLoading,
  ) async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (placeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a place name')),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }

    isLoading.value = true;

    try {
      if (reminder != null) {
        // Update existing reminder
        final updatedReminder = reminder!.copyWith(
          title: titleController.text.trim(),
          notes: notesController.text.trim(),
          placeName: placeNameController.text.trim(),
          address: addressController.text.trim(),
          triggerType: triggerType,
          radiusMeters: radiusMeters,
          dwellMinutes: triggerType == TriggerType.dwell ? dwellMinutes : null,
          cooldownMinutes: cooldownMinutes,
        );
        await ref.read(reminderNotifierProvider.notifier).updateReminder(updatedReminder);
      } else {
        // Create new reminder
        await ref.read(reminderNotifierProvider.notifier).createReminder(
          title: titleController.text.trim(),
          notes: notesController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          triggerType: triggerType,
          dwellMinutes: triggerType == TriggerType.dwell ? dwellMinutes : null,
          placeName: placeNameController.text.trim(),
          address: addressController.text.trim(),
          cooldownMinutes: cooldownMinutes,
        );
      }

      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reminder: $e')),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}