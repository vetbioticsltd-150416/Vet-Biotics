import 'package:flutter/material.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class PetAlertsWidget extends StatelessWidget {
  final Pet pet;
  final PetMedicalSummary? medicalSummary;

  const PetAlertsWidget({super.key, required this.pet, this.medicalSummary});

  @override
  Widget build(BuildContext context) {
    final alerts = _getPetAlerts();

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Text('Cảnh báo', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  List<PetAlert> _getPetAlerts() {
    final alerts = <PetAlert>[];

    // Weight alert
    if (pet.weight == null) {
      alerts.add(
        PetAlert(
          type: AlertType.info,
          title: 'Cập nhật cân nặng',
          message: 'Chưa có thông tin cân nặng của ${pet.name}',
          action: 'Thêm cân nặng',
          actionIcon: Icons.monitor_weight,
        ),
      );
    }

    // Vaccination alert
    if (medicalSummary?.needsVaccination == true) {
      alerts.add(
        PetAlert(
          type: AlertType.warning,
          title: 'Cần tiêm phòng',
          message: '${pet.name} cần được tiêm phòng định kỳ',
          action: 'Đặt lịch tiêm',
          actionIcon: Icons.vaccines,
        ),
      );
    }

    // Medical visit alert (no visits in last 6 months)
    if (medicalSummary?.lastVisitDate != null) {
      final daysSinceLastVisit = DateTime.now().difference(medicalSummary!.lastVisitDate!).inDays;
      if (daysSinceLastVisit > 180) {
        // 6 months
        alerts.add(
          PetAlert(
            type: AlertType.info,
            title: 'Khám định kỳ',
            message: '${pet.name} chưa khám trong ${daysSinceLastVisit ~/ 30} tháng qua',
            action: 'Đặt lịch khám',
            actionIcon: Icons.medical_services,
          ),
        );
      }
    } else {
      alerts.add(
        PetAlert(
          type: AlertType.info,
          title: 'Khám tổng quát',
          message: '${pet.name} chưa từng khám tại phòng khám',
          action: 'Đặt lịch khám',
          actionIcon: Icons.medical_services,
        ),
      );
    }

    // Age-based alerts
    if (pet.ageInYears != null) {
      if (pet.isYoung && pet.ageInMonths! < 6) {
        alerts.add(
          PetAlert(
            type: AlertType.info,
            title: 'Chăm sóc thú cưng con',
            message: '${pet.name} cần chăm sóc đặc biệt vì còn nhỏ',
            action: 'Xem lịch tiêm',
            actionIcon: Icons.child_care,
          ),
        );
      }

      if (pet.isSenior) {
        alerts.add(
          PetAlert(
            type: AlertType.info,
            title: 'Chăm sóc thú cưng lớn tuổi',
            message: '${pet.name} cần kiểm tra sức khỏe định kỳ',
            action: 'Lịch khám',
            actionIcon: Icons.elderly,
          ),
        );
      }
    }

    // Medication alert
    if (pet.isOnMedication) {
      alerts.add(
        PetAlert(
          type: AlertType.info,
          title: 'Đang dùng thuốc',
          message: '${pet.name} đang trong liệu trình điều trị',
          action: 'Xem đơn thuốc',
          actionIcon: Icons.medication,
        ),
      );
    }

    return alerts;
  }

  Widget _buildAlertItem(PetAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getAlertColor(alert.type).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getAlertIcon(alert.type), color: _getAlertColor(alert.type), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(alert.message, style: AppTheme.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              // TODO: Navigate to appropriate screen based on alert action
            },
            icon: Icon(alert.actionIcon, size: 16),
            label: Text(alert.action),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return AppTheme.warningColor;
      case AlertType.error:
        return Colors.red;
      case AlertType.info:
        return AppTheme.primaryColor;
      case AlertType.success:
        return AppTheme.successColor;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Icons.warning;
      case AlertType.error:
        return Icons.error;
      case AlertType.info:
        return Icons.info;
      case AlertType.success:
        return Icons.check_circle;
    }
  }
}

enum AlertType { info, warning, error, success }

class PetAlert {
  final AlertType type;
  final String title;
  final String message;
  final String action;
  final IconData actionIcon;

  const PetAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.action,
    required this.actionIcon,
  });
}

