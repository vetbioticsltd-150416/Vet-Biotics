import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // System Settings Section
          const Text('System Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Push Notifications'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // Implement notification settings
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Security Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Data Backup'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to backup settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // User Management Section
          const Text('User Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Bulk User Import'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to bulk import
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Role Management'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to role management
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Clinic Management Section
          const Text('Clinic Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Clinic Templates'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to clinic templates
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Location Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to location settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Analytics & Reports Section
          const Text('Analytics & Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Report Scheduling'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to report scheduling
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Export Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to export settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Account Section
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to profile settings
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: () async {
                    // Show logout confirmation
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      // Perform logout
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // App Info Section
          const Text('App Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.info), title: const Text('Version'), subtitle: const Text('1.0.0')),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to help & support
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to terms of service
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
