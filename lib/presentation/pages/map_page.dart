import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pinme/domain/entities/reminder.dart';

import '../../application/notifiers/reminder_notifier.dart';
import '../../infrastructure/services/location_service.dart';

class MapPage extends HookConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapController = useState<GoogleMapController?>(null);
    final currentLocation = useState<Position?>(null);
    final selectedLocation = useState<LatLng?>(null);
    final remindersAsync = ref.watch(reminderNotifierProvider);

    useEffect(() {
      _getCurrentLocation(currentLocation);
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          if (selectedLocation.value != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  () =>
                      _addReminderAtLocation(context, selectedLocation.value!),
            ),
        ],
      ),
      body: remindersAsync.when(
        data:
            (reminders) => GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    currentLocation.value != null
                        ? LatLng(
                          currentLocation.value!.latitude,
                          currentLocation.value!.longitude,
                        )
                        : const LatLng(
                          37.7749,
                          -122.4194,
                        ), // San Francisco default
                zoom: 15,
              ),
              onMapCreated: (controller) => mapController.value = controller,
              onLongPress: (position) => selectedLocation.value = position,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _buildMarkers(reminders, selectedLocation.value),
              circles: _buildCircles(reminders, selectedLocation.value),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton:
          selectedLocation.value != null
              ? FloatingActionButton.extended(
                onPressed:
                    () => _addReminderAtLocation(
                      context,
                      selectedLocation.value!,
                    ),
                label: const Text('Add Reminder Here'),
                icon: const Icon(Icons.add_location),
              )
              : null,
    );
  }

  Set<Marker> _buildMarkers(
    List<Reminder> reminders,
    LatLng? selectedLocation,
  ) {
    final markers = <Marker>{};

    // Add reminder markers
    for (final reminder in reminders) {
      markers.add(
        Marker(
          markerId: MarkerId(reminder.id),
          position: LatLng(reminder.latitude, reminder.longitude),
          infoWindow: InfoWindow(
            title: reminder.title,
            snippet: reminder.placeName,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            reminder.enabled
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueCyan,
          ),
        ),
      );
    }

    // Add selected location marker
    if (selectedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: selectedLocation,
          infoWindow: const InfoWindow(title: 'New Reminder Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles(
    List<Reminder> reminders,
    LatLng? selectedLocation,
  ) {
    final circles = <Circle>{};

    // Add reminder circles
    for (final reminder in reminders) {
      circles.add(
        Circle(
          circleId: CircleId(reminder.id),
          center: LatLng(reminder.latitude, reminder.longitude),
          radius: reminder.radiusMeters,
          fillColor: (reminder.enabled ? Colors.green : Colors.grey)
              .withOpacity(0.2),
          strokeColor: reminder.enabled ? Colors.green : Colors.grey,
          strokeWidth: 2,
        ),
      );
    }

    // Add selected location circle (default 100m radius)
    if (selectedLocation != null) {
      circles.add(
        Circle(
          circleId: const CircleId('selected'),
          center: selectedLocation,
          radius: 100, 
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }

    return circles;
  }

  void _getCurrentLocation(ValueNotifier<Position?> currentLocation) async {
    try {
      final position = await LocationService.getCurrentPosition();
      currentLocation.value = position;
    } catch (e) {
      // Handle error silently
    }
  }

  void _addReminderAtLocation(BuildContext context, LatLng location) {
    context.go(
      '/reminder/new',
      extra: {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'placeName': 'Selected Location',
        'address':
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
      },
    );
  }
}
