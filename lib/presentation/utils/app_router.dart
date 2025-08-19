import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/map_page.dart';
import '../pages/reminder_form_page.dart';
import '../pages/settings_page.dart';
import '../../domain/entities/reminder.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapPage(),
    ),
    GoRoute(
      path: '/reminder/new',
      name: 'new_reminder',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ReminderFormPage(
          initialLatitude: extra?['latitude'] as double?,
          initialLongitude: extra?['longitude'] as double?,
          initialPlaceName: extra?['placeName'] as String?,
          initialAddress: extra?['address'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/reminder/edit/:id',
      name: 'edit_reminder',
      builder: (context, state) {
        final reminder = state.extra as Reminder;
        return ReminderFormPage(reminder: reminder);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);