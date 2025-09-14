import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';

import '../providers/app_clinic_provider.dart';
import '../widgets/appointment_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildClinicHeader(context, provider.currentClinic),
              const SizedBox(height: 24),
              _buildKeyMetrics(context, provider),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildTodayAppointments(context, provider.todayAppointments),
              const SizedBox(height: 24),
              _buildRecentActivity(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClinicHeader(BuildContext context, Clinic? clinic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good Morning', style: AppTheme.headline1),
        const SizedBox(height: 8),
        Text(clinic?.name ?? 'Vet Clinic', style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor)),
        const SizedBox(height: 4),
        Text('Here\'s what\'s happening today', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
      ],
    );
  }

  Widget _buildKeyMetrics(BuildContext context, AppClinicProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Overview', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Appointments',
                provider.todayAppointments.length.toString(),
                Icons.calendar_today,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Revenue',
                '\$${provider.todayRevenue.toStringAsFixed(0)}',
                Icons.attach_money,
                AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Pending',
                provider.pendingAppointments.length.toString(),
                Icons.schedule,
                AppTheme.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Low Stock',
                provider.lowStockItems.length.toString(),
                Icons.inventory,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headline2.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTheme.caption.copyWith(color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                'New Appointment',
                Icons.add,
                AppTheme.primaryColor,
                () => Navigator.pushNamed(context, '/new-appointment'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                'Add Patient',
                Icons.pets,
                AppTheme.secondaryColor,
                () => Navigator.pushNamed(context, '/add-patient'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                'Medical Record',
                Icons.medical_services,
                AppTheme.accentColor,
                () => Navigator.pushNamed(context, '/add-medical-record'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                'Billing',
                Icons.receipt,
                AppTheme.infoColor,
                () => Navigator.pushNamed(context, '/billing'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
        elevation: 2,
        shadowColor: color.withOpacity(0.3),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.button.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments(BuildContext context, List<Appointment> appointments) {
    final todayAppointments = appointments.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Today\'s Appointments', style: AppTheme.headline2),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/appointments'),
              child: Text(
                'View All',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayAppointments.isEmpty)
          _buildEmptyState('No appointments scheduled for today')
        else
          ...todayAppointments.map(
            (appointment) => AppointmentCard(
              appointment: appointment,
              onTap: () => Navigator.pushNamed(context, '/appointment-detail', arguments: appointment),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppTheme.headline2),
        const SizedBox(height: 16),
        _buildActivityItem(
          context,
          'Medical record added for Bella',
          '2 hours ago',
          Icons.medical_services,
          AppTheme.primaryColor,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          context,
          'Payment received from John Doe',
          '4 hours ago',
          Icons.attach_money,
          AppTheme.successColor,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(context, 'New patient registered: Max', '6 hours ago', Icons.pets, AppTheme.secondaryColor),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, String description, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: AppTheme.bodyText2),
              Text(time, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.calendar_today, size: 48, color: AppTheme.textHintColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
