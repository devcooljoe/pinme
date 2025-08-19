import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../infrastructure/services/location_service.dart';
import '../../infrastructure/services/notification_service.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accuracy = useState(LocationAccuracy.balanced);
    final maxGeofences = useState(20);
    final updateInterval = useState(30);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Location Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Location Accuracy'),
            subtitle: Text(_getAccuracyDescription(accuracy.value)),
            trailing: DropdownButton<LocationAccuracy>(
              value: accuracy.value,
              onChanged: (value) => accuracy.value = value!,
              items: const [
                DropdownMenuItem(
                  value: LocationAccuracy.high,
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: LocationAccuracy.balanced,
                  child: Text('Balanced'),
                ),
                DropdownMenuItem(
                  value: LocationAccuracy.low,
                  child: Text('Low'),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Update Interval'),
            subtitle: Text('${updateInterval.value} seconds'),
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: updateInterval.value.toDouble(),
                min: 10,
                max: 300,
                divisions: 29,
                onChanged: (value) => updateInterval.value = value.toInt(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Max Active Geofences'),
            subtitle: Text('${maxGeofences.value} (${Platform.isIOS ? 'iOS limit: ~20' : 'Android limit: ~100'})'),
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: maxGeofences.value.toDouble(),
                min: 5,
                max: 100,
                divisions: 19,
                onChanged: (value) => maxGeofences.value = value.toInt(),
              ),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Location Permission'),
            subtitle: const Text('Required for geofencing'),
            trailing: ElevatedButton(
              onPressed: () => LocationService.openAppSettings(),
              child: const Text('Settings'),
            ),
          ),
          ListTile(
            title: const Text('Notification Permission'),
            subtitle: const Text('Required for reminders'),
            trailing: ElevatedButton(
              onPressed: () => NotificationService.requestPermissions(),
              child: const Text('Request'),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Battery Optimization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Battery Optimization'),
            subtitle: const Text('Disable for reliable background operation'),
            trailing: ElevatedButton(
              onPressed: () => _showBatteryOptimizationDialog(context),
              child: const Text('Info'),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Export Reminders'),
            subtitle: const Text('Save reminders as JSON file'),
            trailing: ElevatedButton(
              onPressed: () => _exportReminders(context),
              child: const Text('Export'),
            ),
          ),
          ListTile(
            title: const Text('Import Reminders'),
            subtitle: const Text('Load reminders from JSON file'),
            trailing: ElevatedButton(
              onPressed: () => _importReminders(context),
              child: const Text('Import'),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('OS Limits'),
            subtitle: const Text('Learn about platform limitations'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => _showLimitsDialog(context),
          ),
        ],
      ),
    );
  }

  String _getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.high:
        return 'Best accuracy, higher battery usage';
      case LocationAccuracy.balanced:
        return 'Good accuracy, balanced battery usage';
      case LocationAccuracy.low:
        return 'Lower accuracy, better battery life';
    }
  }

  void _showBatteryOptimizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Battery Optimization'),
        content: const Text(
          'For reliable background operation, disable battery optimization for PinMe:\n\n'
          '1. Go to Settings > Battery > Battery Optimization\n'
          '2. Find PinMe in the list\n'
          '3. Select "Don\'t optimize"\n\n'
          'This ensures reminders work even when the app is closed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLimitsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platform Limitations'),
        content: const Text(
          'iOS:\n'
          '• Maximum ~20 active geofences\n'
          '• Requires "Always" location permission\n'
          '• May delay triggers to save battery\n\n'
          'Android:\n'
          '• Can handle 50-100 geofences\n'
          '• May be affected by Doze mode\n'
          '• Background restrictions vary by manufacturer\n\n'
          'For best results:\n'
          '• Keep the app in recent apps\n'
          '• Disable battery optimization\n'
          '• Use reasonable geofence sizes (100m+)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportReminders(BuildContext context) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  void _importReminders(BuildContext context) {
    // TODO: Implement import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon')),
    );
  }
}