import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form data
  String? _selectedClinicId;
  String? _selectedPetId;
  AppointmentType _appointmentType = AppointmentType.consultation;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedTime;
  int _durationMinutes = 30;
  String? _notes;
  String? _symptoms;

  // Data
  List<Clinic> _clinics = [];
  List<Pet> _pets = [];
  List<Map<String, dynamic>> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    // Load clinics
    _clinics = await databaseProvider.getClinics() as List<Clinic>;

    // Load user pets
    _pets = await databaseProvider.getUserPets() as List<Pet>;

    setState(() => _isLoading = false);
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedClinicId == null) return;

    setState(() => _isLoading = true);
    final databaseProvider = context.read<DatabaseProvider>();
    _availableSlots = await databaseProvider.getAvailableSlots(_selectedClinicId!, _selectedDate);
    setState(() => _isLoading = false);
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = null;
      });
      await _loadAvailableSlots();
    }
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTime == null || _selectedPetId == null || _selectedClinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final databaseProvider = context.read<DatabaseProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập lại')),
      );
      return;
    }

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: _selectedPetId!,
      ownerId: userId,
      clinicId: _selectedClinicId!,
      scheduledDate: _selectedTime!,
      durationMinutes: _durationMinutes,
      type: _appointmentType,
      status: AppointmentStatus.scheduled,
      notes: _notes,
      symptoms: _symptoms,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    final appointmentId = await databaseProvider.createAppointment(appointment);

    if (appointmentId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lịch thành công!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch hẹn'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                  if (_currentStep == 1) {
                    _loadAvailableSlots();
                  }
                } else {
                  _submitAppointment();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                _buildClinicAndPetStep(),
                _buildDateTimeStep(),
                _buildDetailsStep(),
              ],
            ),
    );
  }

  Step _buildClinicAndPetStep() {
    return Step(
      title: const Text('Chọn phòng khám và thú cưng'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic selection
            DropdownButtonFormField<String>(
              initialValue: _selectedClinicId,
              decoration: const InputDecoration(
                labelText: 'Phòng khám',
                border: OutlineInputBorder(),
              ),
              items: _clinics.map((clinic) {
                return DropdownMenuItem(
                  value: clinic.id,
                  child: Text(clinic.name),
                );
              }).toList(),
              validator: (value) => value == null ? 'Vui lòng chọn phòng khám' : null,
              onChanged: (value) {
                setState(() => _selectedClinicId = value);
              },
            ),
            const SizedBox(height: 16),

            // Pet selection
            DropdownButtonFormField<String>(
              initialValue: _selectedPetId,
              decoration: const InputDecoration(
                labelText: 'Thú cưng',
                border: OutlineInputBorder(),
              ),
              items: _pets.map((pet) {
                return DropdownMenuItem(
                  value: pet.id,
                  child: Text(pet.name),
                );
              }).toList(),
              validator: (value) => value == null ? 'Vui lòng chọn thú cưng' : null,
              onChanged: (value) {
                setState(() => _selectedPetId = value);
              },
            ),
            const SizedBox(height: 16),

            // Appointment type
            DropdownButtonFormField<AppointmentType>(
              initialValue: _appointmentType,
              decoration: const InputDecoration(
                labelText: 'Loại lịch hẹn',
                border: OutlineInputBorder(),
              ),
              items: AppointmentType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _appointmentType = value ?? AppointmentType.consultation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Step _buildDateTimeStep() {
    return Step(
      title: const Text('Chọn ngày và giờ'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date selection
          ListTile(
            title: const Text('Ngày'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDate,
          ),
          const SizedBox(height: 16),

          // Available time slots
          const Text(
            'Thời gian có sẵn:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_availableSlots.isEmpty)
            const Text('Không có thời gian trống cho ngày này')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final time = slot['startTime'] as DateTime;
                final isSelected = _selectedTime == time;

                return ChoiceChip(
                  label: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedTime = selected ? time : null);
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Step _buildDetailsStep() {
    return Step(
      title: const Text('Thông tin chi tiết'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration
          DropdownButtonFormField<int>(
            initialValue: _durationMinutes,
            decoration: const InputDecoration(
              labelText: 'Thời lượng (phút)',
              border: OutlineInputBorder(),
            ),
            items: [15, 30, 45, 60, 90, 120].map((duration) {
              return DropdownMenuItem(
                value: duration,
                child: Text('$duration phút'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _durationMinutes = value ?? 30);
            },
          ),
          const SizedBox(height: 16),

          // Symptoms
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Triệu chứng (tùy chọn)',
              border: OutlineInputBorder(),
              hintText: 'Mô tả triệu chứng của thú cưng',
            ),
            maxLines: 3,
            onChanged: (value) => _symptoms = value,
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Ghi chú (tùy chọn)',
              border: OutlineInputBorder(),
              hintText: 'Thông tin bổ sung',
            ),
            maxLines: 2,
            onChanged: (value) => _notes = value,
          ),
        ],
      ),
    );
  }
}

