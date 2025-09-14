import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  final bool showStatus;
  final bool compact;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.showStatus = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTimeBadge(),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAppointmentInfo()),
                  if (showStatus) _buildStatusBadge(),
                ],
              ),
              if (!compact) ...[const SizedBox(height: 12), _buildAdditionalInfo()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBadge() {
    final timeString =
        '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        timeString,
        style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(appointment.petName, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(
          'Owner: ${appointment.petOwnerName}',
          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        ),
        if (!compact) ...[
          const SizedBox(height: 2),
          Text(appointment.serviceType, style: AppTheme.caption.copyWith(color: AppTheme.primaryColor)),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(),
        style: AppTheme.caption.copyWith(color: _getStatusColor(), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(appointment.clinicName, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
        ),
        const SizedBox(width: 12),
        Icon(Icons.phone, size: 16, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 4),
        Text(appointment.contactNumber, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
      ],
    );
  }

  String _getStatusText() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.pending:
        return AppTheme.warningColor;
      case AppointmentStatus.confirmed:
        return AppTheme.primaryColor;
      case AppointmentStatus.inProgress:
        return AppTheme.accentColor;
      case AppointmentStatus.completed:
        return AppTheme.successColor;
      case AppointmentStatus.cancelled:
        return AppTheme.errorColor;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }
}
