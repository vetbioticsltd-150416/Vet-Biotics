import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';
import '../../widgets/patient_card.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String _searchQuery = '';
  String? _speciesFilter;
  Gender? _genderFilter;
  bool _showOwnerInfo = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Patients', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
              IconButton(icon: const Icon(Icons.add), onPressed: () => Navigator.pushNamed(context, '/add-patient')),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(child: _buildPatientList(provider.patients, provider.petOwners)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search patients...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(_showOwnerInfo ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showOwnerInfo = !_showOwnerInfo;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_speciesFilter != null || _genderFilter != null)
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  if (_speciesFilter != null)
                    Chip(
                      label: Text('$_speciesFilter only'),
                      onDeleted: () {
                        setState(() {
                          _speciesFilter = null;
                        });
                      },
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.primaryColor,
                    ),
                  if (_genderFilter != null)
                    Chip(
                      label: Text(_genderFilter == Gender.male ? 'Males only' : 'Females only'),
                      onDeleted: () {
                        setState(() {
                          _genderFilter = null;
                        });
                      },
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.secondaryColor,
                    ),
                ],
              ),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                _speciesFilter = null;
                _genderFilter = null;
              });
            },
            child: Text(
              'Clear All',
              style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(List<Pet> patients, List<User> owners) {
    final filteredPatients = _filterPatients(patients);

    if (filteredPatients.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = filteredPatients[index];
        final owner = _findOwner(owners, patient.ownerId);

        return PatientCard(
          patient: patient,
          owner: owner,
          showOwnerInfo: _showOwnerInfo,
          onTap: () => Navigator.pushNamed(context, '/patient-detail', arguments: patient),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 80, color: AppTheme.textHintColor),
          const SizedBox(height: 24),
          Text('No patients found', style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            'Patients will appear here when registered',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-patient'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
              child: Text('Add Patient', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<Pet> _filterPatients(List<Pet> patients) {
    return patients.where((patient) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          patient.name.toLowerCase().contains(_searchQuery) ||
          patient.species.toLowerCase().contains(_searchQuery) ||
          patient.breed.toLowerCase().contains(_searchQuery);

      // Species filter
      final matchesSpecies = _speciesFilter == null || patient.species.toLowerCase() == _speciesFilter!.toLowerCase();

      // Gender filter
      final matchesGender = _genderFilter == null || patient.gender == _genderFilter;

      return matchesSearch && matchesSpecies && matchesGender;
    }).toList();
  }

  User? _findOwner(List<User> owners, String ownerId) {
    return owners.cast<User?>().firstWhere((owner) => owner?.id == ownerId, orElse: () => null);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Filter Patients', style: AppTheme.headline2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Species', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Hamster', 'Fish'].map((species) {
                  return FilterChip(
                    label: Text(species),
                    selected: _speciesFilter == species,
                    onSelected: (selected) {
                      setState(() {
                        _speciesFilter = selected ? species : null;
                      });
                      this.setState(() {});
                    },
                    backgroundColor: AppTheme.surfaceColor,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Gender', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('Male'),
                      selected: _genderFilter == Gender.male,
                      onSelected: (selected) {
                        setState(() {
                          _genderFilter = selected ? Gender.male : null;
                        });
                        this.setState(() {});
                      },
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      label: const Text('Female'),
                      selected: _genderFilter == Gender.female,
                      onSelected: (selected) {
                        setState(() {
                          _genderFilter = selected ? Gender.female : null;
                        });
                        this.setState(() {});
                      },
                      backgroundColor: AppTheme.surfaceColor,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _speciesFilter = null;
                  _genderFilter = null;
                });
                this.setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Clear All', style: AppTheme.button.copyWith(color: AppTheme.primaryColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: Text('Apply', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
