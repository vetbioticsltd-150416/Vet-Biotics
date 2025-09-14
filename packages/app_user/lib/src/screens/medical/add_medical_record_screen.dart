import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String petId;

  const AddMedicalRecordScreen({super.key, required this.petId});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperatureController = TextEditingController();

  MedicalRecordType _recordType = MedicalRecordType.consultation;
  DateTime _recordDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() => _recordDate = pickedDate);
    }
  }

  Future<void> _saveMedicalRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập lại')));
      return;
    }

    // TODO: Get clinic ID from user profile or appointment
    const clinicId = 'clinic_123'; // Mock clinic ID
    final doctorId = 'doctor_123'; // Mock doctor ID

    final medicalRecord = MedicalRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: widget.petId,
      appointmentId: 'appointment_${DateTime.now().millisecondsSinceEpoch}', // TODO: Link to actual appointment
      doctorId: doctorId,
      clinicId: clinicId,
      type: _recordType,
      recordDate: _recordDate,
      symptoms: _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
      diagnosis: _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
      treatment: _treatmentController.text.trim().isEmpty ? null : _treatmentController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      weight: _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
      temperature: _temperatureController.text.trim().isEmpty ? null : _temperatureController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    final recordId = await databaseProvider.createMedicalRecord(medicalRecord);

    setState(() => _isLoading = false);

    if (recordId != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu bản ghi y tế')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm bản ghi y tế'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedicalRecord,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Record Type
              DropdownButtonFormField<MedicalRecordType>(
                initialValue: _recordType,
                decoration: const InputDecoration(labelText: 'Loại bản ghi', border: OutlineInputBorder()),
                items: MedicalRecordType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.displayName));
                }).toList(),
                onChanged: (value) {
                  setState(() => _recordType = value ?? MedicalRecordType.consultation);
                },
              ),
              const SizedBox(height: 16),

              // Record Date
              ListTile(
                title: const Text('Ngày ghi nhận'),
                subtitle: Text('${_recordDate.day}/${_recordDate.month}/${_recordDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Symptoms
              TextFormField(
                controller: _symptomsController,
                decoration: const InputDecoration(
                  labelText: 'Triệu chứng',
                  border: OutlineInputBorder(),
                  hintText: 'Mô tả các triệu chứng của thú cưng',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập triệu chứng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Diagnosis
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Chẩn đoán',
                  border: OutlineInputBorder(),
                  hintText: 'Kết quả chẩn đoán',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập chẩn đoán';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Treatment
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  labelText: 'Điều trị',
                  border: OutlineInputBorder(),
                  hintText: 'Phương pháp điều trị',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập phương pháp điều trị';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vital Signs Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(labelText: 'Cân nặng (kg)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _temperatureController,
                      decoration: const InputDecoration(labelText: 'Nhiệt độ (°C)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú bổ sung',
                  border: OutlineInputBorder(),
                  hintText: 'Thông tin bổ sung',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicalRecord,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Lưu bản ghi y tế'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

