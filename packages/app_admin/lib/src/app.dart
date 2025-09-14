import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_router/router.dart' as router;
import 'package:vet_biotics_shared/shared.dart';

import '../firebase_options.dart';
import 'providers/app_admin_provider.dart';

class AppAdmin extends StatelessWidget {
  const AppAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        SharedPreferences.getInstance(),
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Failed to initialize app'),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString()),
                  ],
                ),
              ),
            ),
          );
        }

        final sharedPreferences = snapshot.data![0] as SharedPreferences;
        final authProvider = AuthProvider(sharedPreferences);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
            ChangeNotifierProvider(create: (_) => DatabaseProvider()),
            ChangeNotifierProvider(create: (_) => AppAdminProvider()),
          ],
          child: MaterialApp.router(
            title: 'VetBiotics Admin',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router.AdminRouter(authProvider).router,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
