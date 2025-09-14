import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_admin_provider.dart';
import '../../widgets/analytics_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Consumer<AppAdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final analyticsData = provider.analyticsData;

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh analytics data
              await Future.delayed(const Duration(seconds: 1));
              provider.loadMockData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue Analytics
                  const Text('Revenue Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: AnalyticsChart(
                              data: analyticsData['monthlyRevenue'] ?? [],
                              dataKey: 'revenue',
                              labelKey: 'month',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Clinic Performance
                  const Text('Clinic Performance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointments & Revenue by Clinic',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          _buildClinicPerformanceTable(analyticsData['clinicPerformance'] ?? []),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // User Registrations
                  const Text('User Growth', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly User Registrations',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: AnalyticsChart(
                              data: analyticsData['userRegistrations'] ?? [],
                              dataKey: 'count',
                              labelKey: 'month',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Summary Statistics
                  const Text('Summary Statistics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildSummaryCard('Total Clinics', provider.totalClinics.toString(), Icons.business, Colors.blue),
                      _buildSummaryCard('Total Users', provider.totalUsers.toString(), Icons.people, Colors.green),
                      _buildSummaryCard(
                        'Total Appointments',
                        provider.totalAppointments.toString(),
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                      _buildSummaryCard(
                        'Total Revenue',
                        '\$${provider.totalRevenue.toStringAsFixed(0)}',
                        Icons.attach_money,
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Export Reports Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Export reports functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report export functionality will be implemented')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Export Reports'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClinicPerformanceTable(List<dynamic> clinicData) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        // Header
        const TableRow(
          decoration: BoxDecoration(color: Colors.grey),
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Clinic',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Appointments',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Revenue',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        // Data rows
        ...clinicData.map(
          (clinic) => TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(8.0), child: Text(clinic['clinic'])),
              Padding(padding: const EdgeInsets.all(8.0), child: Text(clinic['appointments'].toString())),
              Padding(padding: const EdgeInsets.all(8.0), child: Text('\$${clinic['revenue'].toStringAsFixed(0)}')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
