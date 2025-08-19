import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'infrastructure/datasources/reminder_model.dart';
import 'infrastructure/datasources/settings_model.dart';
import 'infrastructure/services/notification_service.dart';
import 'infrastructure/services/geofence_service.dart';
import 'presentation/utils/app_router.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Handle background tasks
    switch (task) {
      case 'geofence_check':
        // Periodic geofence status check
        break;
      case 'reminder_cleanup':
        // Clean up old notifications
        break;
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());
  
  // Initialize services
  await NotificationService.initialize();
  await PinMeGeofenceService.initialize();
  
  // Initialize background tasks
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  runApp(
    const ProviderScope(
      child: PinMeApp(),
    ),
  );
}

class PinMeApp extends StatelessWidget {
  const PinMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PinMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
