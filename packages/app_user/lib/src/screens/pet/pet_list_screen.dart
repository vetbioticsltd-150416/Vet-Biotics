import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import '../../providers/app_user_provider.dart';
import '../../widgets/pet_card.dart';
import 'pet_detail_screen.dart';

class PetListScreen extends StatelessWidget {
  const PetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pets', style: AppTheme.headline2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pushNamed(context, '/add-pet'),
          ),
        ],
      ),
      body: Consumer<AppUserProvider>(
        builder: (context, provider, child) {
          final pets = provider.pets;

          if (pets.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return PetCard(
                pet: pet,
                onTap: () =>
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailScreen(petId: pet.id!))),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: AppTheme.textHintColor),
          const SizedBox(height: 24),
          Text('No pets added yet', style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            'Add your first pet to get started',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-pet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
              child: Text('Add Pet', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
