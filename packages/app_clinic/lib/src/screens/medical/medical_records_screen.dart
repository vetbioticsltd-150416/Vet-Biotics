import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';
import '../../widgets/medical_record_card.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  String _searchQuery = '';
  String? _recordTypeFilter;
  String? _petFilter;
  DateTimeRange? _dateRangeFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Medical Records', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.pushNamed(context, '/add-medical-record'),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(child: _buildMedicalRecordsList(provider)),
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
          hintText: 'Search medical records...',
          prefixIcon: const Icon(Icons.search),
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
          if (_recordTypeFilter != null || _petFilter != null || _dateRangeFilter != null)
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  if (_recordTypeFilter != null)
                    Chip(
                      label: Text(_recordTypeFilter!),
                      onDeleted: () {
                        setState(() {
                          _recordTypeFilter = null;
                        });
                      },
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.primaryColor,
                    ),
                  if (_petFilter != null)
                    Chip(
                      label: Text(_petFilter!),
                      onDeleted: () {
                        setState(() {
                          _petFilter = null;
                        });
                      },
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.secondaryColor,
                    ),
                  if (_dateRangeFilter != null)
                    Chip(
                      label: Text('${_formatDate(_dateRangeFilter!.start)} - ${_formatDate(_dateRangeFilter!.end)}'),
                      onDeleted: () {
                        setState(() {
                          _dateRangeFilter = null;
                        });
                      },
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.accentColor,
                    ),
                ],
              ),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                _recordTypeFilter = null;
                _petFilter = null;
                _dateRangeFilter = null;
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

  Widget _buildMedicalRecordsList(AppClinicProvider provider) {
    final filteredRecords = _filterMedicalRecords(provider);

    if (filteredRecords.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        final pet = provider.patients.firstWhere((p) => p.id == record.petId, orElse: () => Pet.empty());

        return MedicalRecordCard(
          record: record,
          pet: pet.id.isNotEmpty ? pet : null,
          onTap: () => _showRecordDetails(context, record, pet),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 80, color: AppTheme.textHintColor),
          const SizedBox(height: 24),
          Text('No medical records found', style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            'Medical records will appear here when added',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-medical-record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
              child: Text('Add Medical Record', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<MedicalRecord> _filterMedicalRecords(AppClinicProvider provider) {
    return provider.recentMedicalRecords.where((record) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          record.diagnosis?.toLowerCase().contains(_searchQuery) == true ||
          record.treatment?.toLowerCase().contains(_searchQuery) == true ||
          record.veterinarianName?.toLowerCase().contains(_searchQuery) == true ||
          _getPetName(provider, record.petId).toLowerCase().contains(_searchQuery);

      // Type filter
      final matchesType = _recordTypeFilter == null || record.type.toLowerCase() == _recordTypeFilter!.toLowerCase();

      // Pet filter
      final matchesPet = _petFilter == null || _getPetName(provider, record.petId) == _petFilter;

      // Date range filter
      final matchesDateRange =
          _dateRangeFilter == null ||
          (record.date.isAfter(_dateRangeFilter!.start.subtract(const Duration(days: 1))) &&
              record.date.isBefore(_dateRangeFilter!.end.add(const Duration(days: 1))));

      return matchesSearch && matchesType && matchesPet && matchesDateRange;
    }).toList()..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  String _getPetName(AppClinicProvider provider, String petId) {
    final pet = provider.patients.firstWhere((p) => p.id == petId, orElse: () => Pet.empty());
    return pet.id.isNotEmpty ? pet.name : 'Unknown Pet';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Filter Medical Records', style: AppTheme.headline2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Type', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Check-up', 'Vaccination', 'Surgery', 'Emergency', 'Dental', 'Grooming'].map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: _recordTypeFilter == type,
                    onSelected: (selected) {
                      setState(() {
                        _recordTypeFilter = selected ? type : null;
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
              Text('Pet', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Consumer<AppClinicProvider>(
                builder: (context, provider, child) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.patients.map((pet) {
                      return FilterChip(
                        label: Text(pet.name),
                        selected: _petFilter == pet.name,
                        onSelected: (selected) {
                          setState(() {
                            _petFilter = selected ? pet.name : null;
                          });
                          this.setState(() {});
                        },
                        backgroundColor: AppTheme.surfaceColor,
                        selectedColor: AppTheme.secondaryColor.withOpacity(0.1),
                        checkmarkColor: AppTheme.secondaryColor,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Date Range', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _dateRangeFilter,
                        );
                        if (picked != null) {
                          setState(() {
                            _dateRangeFilter = picked;
                          });
                          this.setState(() {});
                        }
                      },
                      child: Text(
                        _dateRangeFilter != null
                            ? '${_formatDate(_dateRangeFilter!.start)} - ${_formatDate(_dateRangeFilter!.end)}'
                            : 'Select Date Range',
                        style: AppTheme.bodyText2,
                      ),
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
                  _recordTypeFilter = null;
                  _petFilter = null;
                  _dateRangeFilter = null;
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

  void _showRecordDetails(BuildContext context, MedicalRecord record, Pet pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Medical Record Details', style: AppTheme.headline2),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Pet Information', [
                'Name: ${pet.name}',
                'Species: ${pet.species}',
                'Breed: ${pet.breed}',
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Record Information', [
                'Date: ${_formatDate(record.date)}',
                'Type: ${record.type}',
                'Veterinarian: ${record.veterinarianName ?? 'Not specified'}',
              ]),
              if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Symptoms', [record.symptoms!]),
              ],
              if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Diagnosis', [record.diagnosis!]),
              ],
              if (record.treatment != null && record.treatment!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Treatment', [record.treatment!]),
              ],
              if (record.medications != null && record.medications!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Medications', [record.medications!]),
              ],
              if (record.followUpDate != null) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Follow-up', [_formatDate(record.followUpDate!)]),
              ],
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection('Notes', [record.notes!]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...details.map(
          (detail) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(detail, style: AppTheme.bodyText2),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
