import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_admin_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Consumer<AppAdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh dashboard data
              await Future.delayed(const Duration(seconds: 1));
              provider.loadMockData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Metrics Section
                  const Text('Key Metrics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      StatCard(
                        title: 'Total Clinics',
                        value: provider.totalClinics.toString(),
                        icon: Icons.business,
                        color: Colors.blue,
                      ),
                      StatCard(
                        title: 'Total Users',
                        value: provider.totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.green,
                      ),
                      StatCard(
                        title: 'Total Appointments',
                        value: provider.totalAppointments.toString(),
                        icon: Icons.calendar_today,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: 'Total Revenue',
                        value: '\$${provider.totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions Section
                  const Text('Quick Actions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildQuickActionCard(context, 'Add Clinic', Icons.add_business, Colors.blue, () {
                        // Navigate to add clinic screen
                        Navigator.pushNamed(context, '/admin/clinics/add');
                      }),
                      _buildQuickActionCard(context, 'Add User', Icons.person_add, Colors.green, () {
                        // Navigate to add user screen
                        Navigator.pushNamed(context, '/admin/users/add');
                      }),
                      _buildQuickActionCard(context, 'View Analytics', Icons.analytics, Colors.orange, () {
                        // Navigate to analytics screen
                        Navigator.pushNamed(context, '/admin/analytics');
                      }),
                      _buildQuickActionCard(context, 'Settings', Icons.settings, Colors.purple, () {
                        // Navigate to settings screen
                        Navigator.pushNamed(context, '/admin/settings');
                      }),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity Section
                  const Text('Recent Activity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRecentActivityList(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(BuildContext context) {
    final activities = [
      {'action': 'New clinic registered', 'clinic': 'Central Pet Clinic', 'time': '2 hours ago'},
      {'action': 'User account created', 'clinic': 'Dr. John Smith', 'time': '4 hours ago'},
      {'action': 'Clinic deactivated', 'clinic': 'Suburban Animal Hospital', 'time': '1 day ago'},
      {'action': 'Monthly report generated', 'clinic': 'System', 'time': '2 days ago'},
      {'action': 'New user registered', 'clinic': 'Dr. Sarah Johnson', 'time': '3 days ago'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text(activity['action']!),
            subtitle: Text('${activity['clinic']} • ${activity['time']}'),
          ),
        );
      },
    );
  }
}
