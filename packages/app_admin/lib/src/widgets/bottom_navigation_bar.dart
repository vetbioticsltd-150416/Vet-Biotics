import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/app_admin_provider.dart';

class AdminBottomNavigationBar extends StatelessWidget {
  const AdminBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAdminProvider>(
      builder: (context, provider, child) {
        return BottomNavigationBar(
          currentIndex: provider.currentIndex,
          onTap: (index) {
            provider.setCurrentIndex(index);
            // Handle navigation based on index
            switch (index) {
              case 0:
                context.go('/admin/dashboard');
                break;
              case 1:
                context.go('/admin/clinics');
                break;
              case 2:
                context.go('/admin/users');
                break;
              case 3:
                context.go('/admin/analytics');
                break;
              case 4:
                context.go('/admin/settings');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Clinics'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        );
      },
    );
  }
}
