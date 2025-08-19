import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reminder.dart';
import '../../infrastructure/services/location_service.dart';

class ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final Position? currentLocation;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const ReminderListItem({
    super.key,
    required this.reminder,
    this.currentLocation,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance();
    final isInCooldown = reminder.isInCooldown;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: reminder.enabled 
              ? (isInCooldown ? Colors.orange : Colors.green)
              : Colors.grey,
          child: Icon(
            _getTriggerIcon(),
            color: Colors.white,
          ),
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: reminder.enabled ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.placeName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (reminder.notes.isNotEmpty)
              Text(
                reminder.notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              children: [
                Icon(
                  Icons.radio_button_unchecked,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${reminder.radiusMeters.toInt()}m',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (distance != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(distance),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
            if (isInCooldown)
              Text(
                'In cooldown until ${_formatCooldownEnd()}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: Switch(
          value: reminder.enabled,
          onChanged: (_) => onToggle(),
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getTriggerIcon() {
    switch (reminder.triggerType) {
      case TriggerType.enter:
        return Icons.login;
      case TriggerType.exit:
        return Icons.logout;
      case TriggerType.dwell:
        return Icons.access_time;
    }
  }

  double? _calculateDistance() {
    if (currentLocation == null) return null;
    
    return LocationService.calculateDistance(
      currentLocation!.latitude,
      currentLocation!.longitude,
      reminder.latitude,
      reminder.longitude,
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toInt()}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  String _formatCooldownEnd() {
    if (reminder.lastTriggeredAt == null) return '';
    
    final cooldownEnd = reminder.lastTriggeredAt!
        .add(Duration(minutes: reminder.cooldownMinutes));
    
    return DateFormat('HH:mm').format(cooldownEnd);
  }
}