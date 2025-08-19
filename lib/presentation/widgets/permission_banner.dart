import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../infrastructure/services/location_service.dart';

class PermissionBanner extends HookWidget {
  const PermissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final permissionStatus = useState<PermissionStatus?>(null);
    final isLocationEnabled = useState<bool?>(null);

    useEffect(() {
      _checkPermissions(permissionStatus, isLocationEnabled);
      return null;
    }, []);

    if (permissionStatus.value == PermissionStatus.granted && 
        isLocationEnabled.value == true) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.orange[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                'Location Setup Required',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLocationEnabled.value == false)
            _buildLocationServicesBanner(context, isLocationEnabled),
          if (permissionStatus.value != PermissionStatus.granted)
            _buildPermissionBanner(context, permissionStatus.value, permissionStatus),
        ],
      ),
    );
  }

  Widget _buildLocationServicesBanner(
    BuildContext context,
    ValueNotifier<bool?> isLocationEnabled,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location services are disabled.'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            await LocationService.openLocationSettings();
            _checkPermissions(ValueNotifier(null), isLocationEnabled);
          },
          child: const Text('Enable Location Services'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    PermissionStatus? status,
    ValueNotifier<PermissionStatus?> permissionStatus,
  ) {
    String message;
    String buttonText;
    VoidCallback? onPressed;

    switch (status) {
      case PermissionStatus.denied:
        message = 'Location permission is required for reminders to work.';
        buttonText = 'Grant Permission';
        onPressed = () async {
          final result = await LocationService.requestAlwaysLocationPermission();
          if (result) {
            permissionStatus.value = PermissionStatus.granted;
          }
        };
        break;
      case PermissionStatus.permanentlyDenied:
        message = 'Location permission was denied. Please enable it in settings.';
        buttonText = 'Open Settings';
        onPressed = () => LocationService.openAppSettings();
        break;
      case PermissionStatus.restricted:
        message = 'Location access is restricted on this device.';
        buttonText = 'Open Settings';
        onPressed = () => LocationService.openAppSettings();
        break;
      default:
        message = 'Always location permission is needed for background reminders.';
        buttonText = 'Grant Always Permission';
        onPressed = () async {
          final result = await LocationService.requestAlwaysLocationPermission();
          if (result) {
            permissionStatus.value = PermissionStatus.granted;
          }
        };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }

  void _checkPermissions(
    ValueNotifier<PermissionStatus?> permissionStatus,
    ValueNotifier<bool?> isLocationEnabled,
  ) async {
    final status = await LocationService.getLocationPermissionStatus();
    final enabled = await LocationService.isLocationServiceEnabled();
    
    permissionStatus.value = status;
    isLocationEnabled.value = enabled;
  }
}