import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';

class PatientCard extends StatelessWidget {
  final Pet patient;
  final User? owner;
  final VoidCallback? onTap;
  final bool showOwnerInfo;

  const PatientCard({super.key, required this.patient, this.owner, this.onTap, this.showOwnerInfo = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPetAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPetInfo(),
                    if (showOwnerInfo && owner != null) ...[const SizedBox(height: 8), _buildOwnerInfo()],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getPetColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPetColor().withOpacity(0.3), width: 2),
      ),
      child: Icon(_getPetIcon(), color: _getPetColor(), size: 32),
    );
  }

  Widget _buildPetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(patient.name, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: patient.gender == Gender.male
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                patient.gender == Gender.male ? '♂' : '♀',
                style: AppTheme.caption.copyWith(
                  color: patient.gender == Gender.male ? AppTheme.primaryColor : AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${patient.species} • ${patient.breed}',
          style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 2),
        Text('Age: ${_calculateAge()}', style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
      ],
    );
  }

  Widget _buildOwnerInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 16, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              owner?.name ?? 'Owner not found',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (owner?.phone != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.phone, size: 14, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 4),
            Text(owner!.phone!, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ],
      ),
    );
  }

  String _calculateAge() {
    final now = DateTime.now();
    final age = now.difference(patient.birthDate);

    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years year${years > 1 ? 's' : ''}';
    } else if (months > 0) {
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${age.inDays} day${age.inDays > 1 ? 's' : ''}';
    }
  }

  IconData _getPetIcon() {
    switch (patient.species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.air;
      case 'fish':
        return Icons.water;
      case 'rabbit':
        return Icons.pets;
      case 'hamster':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  Color _getPetColor() {
    switch (patient.species.toLowerCase()) {
      case 'dog':
        return AppTheme.primaryColor;
      case 'cat':
        return AppTheme.secondaryColor;
      case 'bird':
        return AppTheme.accentColor;
      case 'fish':
        return AppTheme.infoColor;
      case 'rabbit':
        return Colors.orange;
      case 'hamster':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }
}
