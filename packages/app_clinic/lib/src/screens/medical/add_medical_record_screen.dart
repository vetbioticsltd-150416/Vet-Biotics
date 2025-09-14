import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final Pet? patient;

  const AddMedicalRecordScreen({super.key, this.patient});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedRecordType = 'Check-up';
  Pet? _selectedPatient;
  DateTime _selectedDate = DateTime.now();
  DateTime? _followUpDate;
  bool _isLoading = false;

  final List<String> _recordTypes = [
    'Check-up',
    'Vaccination',
    'Surgery',
    'Emergency',
    'Dental',
    'Grooming',
    'Consultation',
    'Laboratory',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.patient;
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Add Medical Record', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: _isLoading ? null : _saveRecord,
                child: Text('Save', style: AppTheme.button.copyWith(color: AppTheme.primaryColor)),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPatientSelection(provider),
                        const SizedBox(height: 24),
                        _buildRecordTypeSelection(),
                        const SizedBox(height: 24),
                        _buildDateSelection(),
                        const SizedBox(height: 24),
                        _buildMedicalDetails(),
                        const SizedBox(height: 24),
                        _buildFollowUpSection(),
                        const SizedBox(height: 24),
                        _buildNotesSection(),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPatientSelection(AppClinicProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Patient', style: AppTheme.headline2),
        const SizedBox(height: 16),
        if (_selectedPatient != null) ...[
          _buildSelectedPatientCard(),
        ] else ...[
          DropdownButtonFormField<Pet>(
            decoration: InputDecoration(
              hintText: 'Select a patient',
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
            initialValue: _selectedPatient,
            items: provider.patients.map((pet) {
              return DropdownMenuItem(value: pet, child: Text('${pet.name} (${pet.species})'));
            }).toList(),
            onChanged: (pet) {
              setState(() {
                _selectedPatient = pet;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a patient';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.pets, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedPatient!.name,
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                ),
                Text(
                  '${_selectedPatient!.species} • ${_selectedPatient!.breed}',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                _selectedPatient = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Record Type', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recordTypes.map((type) {
            return ChoiceChip(
              label: Text(type),
              selected: _selectedRecordType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedRecordType = type;
                  });
                }
              },
              backgroundColor: AppTheme.surfaceColor,
              selectedColor: AppTheme.primaryColor.withOpacity(0.1),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: AppTheme.bodyText2.copyWith(
                color: _selectedRecordType == type ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: AppTheme.headline2),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: AppTheme.bodyText1),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: AppTheme.textSecondaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medical Details', style: AppTheme.headline2),
        const SizedBox(height: 16),
        TextFormField(
          controller: _symptomsController,
          decoration: InputDecoration(
            labelText: 'Symptoms',
            hintText: 'Describe the symptoms observed...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            filled: true,
            fillColor: AppTheme.surfaceColor,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _diagnosisController,
          decoration: InputDecoration(
            labelText: 'Diagnosis',
            hintText: 'Enter diagnosis...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            filled: true,
            fillColor: AppTheme.surfaceColor,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _treatmentController,
          decoration: InputDecoration(
            labelText: 'Treatment',
            hintText: 'Describe the treatment provided...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            filled: true,
            fillColor: AppTheme.surfaceColor,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _medicationsController,
          decoration: InputDecoration(
            labelText: 'Medications',
            hintText: 'List medications prescribed...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            filled: true,
            fillColor: AppTheme.surfaceColor,
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Follow-up', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Schedule follow-up appointment', style: AppTheme.bodyText2),
            const Spacer(),
            Switch(
              value: _followUpDate != null,
              onChanged: (value) async {
                if (value) {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _followUpDate = picked;
                    });
                  }
                } else {
                  setState(() {
                    _followUpDate = null;
                  });
                }
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
          ],
        ),
        if (_followUpDate != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Text(
                  'Follow-up: ${_followUpDate!.day}/${_followUpDate!.month}/${_followUpDate!.year}',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.accentColor),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Notes', style: AppTheme.headline2),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Add any additional notes...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            filled: true,
            fillColor: AppTheme.surfaceColor,
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  void _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a patient', style: TextStyle(color: AppTheme.surfaceColor)),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<AppClinicProvider>();
      final record = MedicalRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: _selectedPatient!.id,
        date: _selectedDate,
        type: _selectedRecordType,
        symptoms: _symptomsController.text.trim().isNotEmpty ? _symptomsController.text.trim() : null,
        diagnosis: _diagnosisController.text.trim().isNotEmpty ? _diagnosisController.text.trim() : null,
        treatment: _treatmentController.text.trim().isNotEmpty ? _treatmentController.text.trim() : null,
        medications: _medicationsController.text.trim().isNotEmpty ? _medicationsController.text.trim() : null,
        followUpDate: _followUpDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        veterinarianName: provider.currentClinic?.name ?? 'Clinic Veterinarian', // TODO: Get current user
      );

      provider.addMedicalRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medical record added successfully', style: TextStyle(color: AppTheme.surfaceColor)),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medical record', style: TextStyle(color: AppTheme.surfaceColor)),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
