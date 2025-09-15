import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_router/router.dart';
import 'package:vet_biotics_shared/shared.dart';

import 'providers/app_clinic_provider.dart';

class AppClinic extends StatelessWidget {
  const AppClinic({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
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

        var sharedPreferences = snapshot.data!;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthProvider(sharedPreferences)),
            ChangeNotifierProvider(create: (context) => DatabaseProvider()),
            ChangeNotifierProvider(create: (context) => AppClinicProvider()),
          ],
          child: MaterialApp.router(
            title: 'Vet Biotics - Clinic',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
}
