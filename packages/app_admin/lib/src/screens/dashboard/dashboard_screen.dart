import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

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
            return const Center(
              child: EnhancedLoadingIndicator(
                message: 'Đang tải dữ liệu...',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh dashboard data
              await Future.delayed(const Duration(seconds: 1));
              provider.loadMockData();
            },
              child: ResponsiveContainer(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Metrics Section
                      const ResponsiveText(
                        'Key Metrics',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ResponsiveGridView(
                        children: [
                          AnimatedListItem(
                            index: 0,
                            child: StatCard(
                              title: 'Total Clinics',
                              value: provider.totalClinics.toString(),
                              icon: Icons.business,
                              color: Colors.blue,
                            ),
                          ),
                          AnimatedListItem(
                            index: 1,
                            child: StatCard(
                              title: 'Total Users',
                              value: provider.totalUsers.toString(),
                              icon: Icons.people,
                              color: Colors.green,
                            ),
                          ),
                          AnimatedListItem(
                            index: 2,
                            child: StatCard(
                              title: 'Total Appointments',
                              value: provider.totalAppointments.toString(),
                              icon: Icons.calendar_today,
                              color: Colors.orange,
                            ),
                          ),
                          AnimatedListItem(
                            index: 3,
                            child: StatCard(
                              title: 'Total Revenue',
                              value: '\$${provider.totalRevenue.toStringAsFixed(0)}',
                              icon: Icons.attach_money,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Quick Actions Section
                      const ResponsiveText(
                        'Quick Actions',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ResponsiveGridView(
                        children: [
                          AnimatedListItem(
                            index: 0,
                            child: _buildQuickActionCard(context, 'Add Clinic', Icons.add_business, Colors.blue, () {
                              // Navigate to add clinic screen
                              Navigator.pushNamed(context, '/admin/clinics/add');
                            }),
                          ),
                          AnimatedListItem(
                            index: 1,
                            child: _buildQuickActionCard(context, 'Manage Users', Icons.people, Colors.green, () {
                              // Navigate to users screen
                              context.go('/admin/users');
                            }),
                          ),
                          AnimatedListItem(
                            index: 2,
                            child: _buildQuickActionCard(context, 'View Analytics', Icons.analytics, Colors.orange, () {
                              // Navigate to analytics screen
                              Navigator.pushNamed(context, '/admin/analytics');
                            }),
                          ),
                          AnimatedListItem(
                            index: 3,
                            child: _buildQuickActionCard(context, 'Settings', Icons.settings, Colors.purple, () {
                              // Navigate to settings screen
                              Navigator.pushNamed(context, '/admin/settings');
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Recent Activity Section
                      const ResponsiveText(
                        'Recent Activity',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
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
    return AnimatedCard(
      elevation: 4,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScaleIn(
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
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
        return AnimatedListItem(
          index: index,
          baseDelay: const Duration(milliseconds: 200),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: AnimatedCard(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(activity['action']!),
                subtitle: Text('${activity['clinic']} • ${activity['time']}'),
              ),
            ),
          ),
        );
      },
    );
  }
}
