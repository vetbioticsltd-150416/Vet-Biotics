import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final Pet? pet;
  final VoidCallback? onTap;
  final bool showPetInfo;

  const MedicalRecordCard({super.key, required this.record, this.pet, this.onTap, this.showPetInfo = true});

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
              _buildHeader(),
              const SizedBox(height: 12),
              if (showPetInfo && pet != null) ...[_buildPetInfo(), const SizedBox(height: 12)],
              _buildMedicalDetails(),
              if (record.notes != null && record.notes!.isNotEmpty) ...[const SizedBox(height: 12), _buildNotes()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(record.date), style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
            Text(
              record.veterinarianName ?? 'Veterinarian',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRecordTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getRecordTypeColor().withOpacity(0.3)),
          ),
          child: Text(
            record.type,
            style: AppTheme.caption.copyWith(color: _getRecordTypeColor(), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPetInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.pets, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${pet!.name} (${pet!.species})',
              style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
          _buildDetailRow('Symptoms', record.symptoms!),
          const SizedBox(height: 8),
        ],
        if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
          _buildDetailRow('Diagnosis', record.diagnosis!),
          const SizedBox(height: 8),
        ],
        if (record.treatment != null && record.treatment!.isNotEmpty) ...[
          _buildDetailRow('Treatment', record.treatment!),
          const SizedBox(height: 8),
        ],
        if (record.medications != null && record.medications!.isNotEmpty) ...[
          _buildDetailRow('Medications', record.medications!),
          const SizedBox(height: 8),
        ],
        if (record.followUpDate != null) ...[_buildDetailRow('Follow-up', _formatDate(record.followUpDate!))],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: AppTheme.bodyText2)),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: AppTheme.infoColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: AppTheme.caption.copyWith(color: AppTheme.infoColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(record.notes!, style: AppTheme.bodyText2.copyWith(color: AppTheme.textPrimaryColor)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRecordTypeColor() {
    switch (record.type.toLowerCase()) {
      case 'check-up':
      case 'vaccination':
        return AppTheme.primaryColor;
      case 'surgery':
        return AppTheme.errorColor;
      case 'emergency':
        return AppTheme.warningColor;
      case 'dental':
        return AppTheme.secondaryColor;
      case 'grooming':
        return AppTheme.accentColor;
      default:
        return AppTheme.infoColor;
    }
  }
}
