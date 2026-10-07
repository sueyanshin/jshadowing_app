import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jshadowing_app/screens/providers/conversation_provider.dart';
import 'package:jshadowing_app/screens/conversation_screen.dart';
import 'package:jshadowing_app/screens/sections_screen.dart';
import 'package:jshadowing_app/screens/units_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConversationProvider(),
      child: MaterialApp.router(routerConfig: _router),
    );
  }
}

final _router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: '/', builder: ((context, state) => (UnitsScreen()))),

    GoRoute(
      path: '/unit/:unitId',
      builder: ((context, state) {
        final rawUnitId = state.pathParameters['unitId']!;
        final unitId = int.parse(rawUnitId);
        return SectionsScreen(unitId: unitId);
      }),
    ),

    GoRoute(
      path: '/unit/:unitId/section/:sectionId',
      builder: ((context, state) {
        final rawUnitId = state.pathParameters['unitId']!;
        final unitId = int.parse(rawUnitId);
        final rawSectionId = state.pathParameters['sectionId']!;
        final sectionId = int.parse(rawSectionId);

        return ConversationScreen(unitId: unitId, sectionId: sectionId);
      }),
    ),
  ],
);
