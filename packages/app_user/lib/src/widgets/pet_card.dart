import 'package:flutter/material.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../utils/date_formatter.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;

  const PetCard({super.key, required this.pet, this.onTap});

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
              Expanded(child: _buildPetInfo()),
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
        Text(pet.name, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${pet.species} • ${pet.breed}', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.cake, size: 14, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 4),
            Text(
              DateFormatter.formatAge(pet.birthDate),
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(width: 12),
            Icon(pet.gender == Gender.male ? Icons.male : Icons.female, size: 14, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 4),
            Text(
              pet.gender == Gender.male ? 'Male' : 'Female',
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getPetIcon() {
    switch (pet.species.toLowerCase()) {
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
    switch (pet.species.toLowerCase()) {
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
