import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';

class PatientDetailScreen extends StatefulWidget {
  final Pet patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Pet _patient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _patient = widget.patient;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        final owner = provider.petOwners.firstWhere((o) => o.id == _patient.ownerId, orElse: () => User.empty());

        return Scaffold(
          appBar: AppBar(
            title: Text(_patient.name, style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Patient')),
                  const PopupMenuItem(value: 'medical-record', child: Text('Add Medical Record')),
                  const PopupMenuItem(value: 'appointment', child: Text('Schedule Appointment')),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Medical History'),
                Tab(text: 'Appointments'),
              ],
              labelStyle: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
              unselectedLabelStyle: AppTheme.bodyText2,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [_buildOverviewTab(owner), _buildMedicalHistoryTab(), _buildAppointmentsTab()],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(User owner) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPetHeader(),
          const SizedBox(height: 24),
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildOwnerInfo(owner),
          const SizedBox(height: 24),
          _buildHealthStatus(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildPetHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getPetColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: _getPetColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: _getPetColor().withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(_getPetIcon(), color: _getPetColor(), size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_patient.name, style: AppTheme.headline1.copyWith(color: _getPetColor())),
                const SizedBox(height: 4),
                Text('${_patient.species} • ${_patient.breed}', style: AppTheme.bodyText1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _patient.gender == Gender.male
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _patient.gender == Gender.male ? Icons.male : Icons.female,
                            size: 16,
                            color: _patient.gender == Gender.male ? AppTheme.primaryColor : AppTheme.secondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _patient.gender == Gender.male ? 'Male' : 'Female',
                            style: AppTheme.caption.copyWith(
                              color: _patient.gender == Gender.male ? AppTheme.primaryColor : AppTheme.secondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Age: ${_calculateAge()}',
                      style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Information', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              _buildInfoRow('Date of Birth', _formatDate(_patient.birthDate)),
              const SizedBox(height: 12),
              _buildInfoRow('Species', _patient.species),
              const SizedBox(height: 12),
              _buildInfoRow('Breed', _patient.breed),
              const SizedBox(height: 12),
              _buildInfoRow('Color', _patient.color ?? 'Not specified'),
              const SizedBox(height: 12),
              _buildInfoRow('Weight', _patient.weight != null ? '${_patient.weight} kg' : 'Not recorded'),
              const SizedBox(height: 12),
              _buildInfoRow('Microchip ID', _patient.microchipId ?? 'Not available'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo(User owner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Owner Information', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text(owner.name, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              if (owner.phone != null) ...[
                Row(
                  children: [
                    Icon(Icons.phone, color: AppTheme.textSecondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(owner.phone!, style: AppTheme.bodyText2),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (owner.email != null) ...[
                Row(
                  children: [
                    Icon(Icons.email, color: AppTheme.textSecondaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(owner.email!, style: AppTheme.bodyText2),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.textSecondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(owner.address ?? 'Address not available', style: AppTheme.bodyText2)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Health Status', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.health_and_safety, color: AppTheme.successColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Health', style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
                    Text(
                      'Good condition - Regular check-ups recommended',
                      style: AppTheme.caption.copyWith(color: AppTheme.successColor.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: AppTheme.headline2),
        const SizedBox(height: 16),
        _buildActivityItem('Vaccination completed', '2 weeks ago', Icons.vaccines, AppTheme.primaryColor),
        const SizedBox(height: 12),
        _buildActivityItem('Weight check: 12.5 kg', '1 month ago', Icons.monitor_weight, AppTheme.secondaryColor),
        const SizedBox(height: 12),
        _buildActivityItem('Dental cleaning', '2 months ago', Icons.health_and_safety, AppTheme.accentColor),
      ],
    );
  }

  Widget _buildMedicalHistoryTab() {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        final medicalRecords = provider.recentMedicalRecords.where((record) => record.petId == _patient.id).toList();

        if (medicalRecords.isEmpty) {
          return _buildEmptyTabState('No medical records', 'Medical records will appear here', Icons.medical_services);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: medicalRecords.length,
          itemBuilder: (context, index) {
            final record = medicalRecords[index];
            return _buildMedicalRecordCard(record);
          },
        );
      },
    );
  }

  Widget _buildAppointmentsTab() {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        final appointments = provider.todayAppointments
            .where((appointment) => appointment.petId == _patient.id)
            .toList();

        if (appointments.isEmpty) {
          return _buildEmptyTabState('No appointments', 'Upcoming appointments will appear here', Icons.calendar_today);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return _buildAppointmentCard(appointment);
          },
        );
      },
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDate(record.date), style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.type,
                    style: AppTheme.caption.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (record.diagnosis != null) ...[
              Text('Diagnosis: ${record.diagnosis}', style: AppTheme.bodyText2),
              const SizedBox(height: 4),
            ],
            if (record.treatment != null) ...[
              Text('Treatment: ${record.treatment}', style: AppTheme.bodyText2),
              const SizedBox(height: 4),
            ],
            if (record.notes != null) ...[
              Text('Notes: ${record.notes}', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(appointment.dateTime),
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAppointmentStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getAppointmentStatusText(appointment.status),
                    style: AppTheme.caption.copyWith(
                      color: _getAppointmentStatusColor(appointment.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(appointment.serviceType, style: AppTheme.bodyText2),
            const SizedBox(height: 4),
            Text(appointment.clinicName, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTabState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textHintColor),
          const SizedBox(height: 16),
          Text(title, style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
        Text(value, style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActivityItem(String description, String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: AppTheme.bodyText2),
              Text(time, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit patient screen
        break;
      case 'medical-record':
        Navigator.pushNamed(context, '/add-medical-record', arguments: _patient);
        break;
      case 'appointment':
        Navigator.pushNamed(context, '/new-appointment');
        break;
    }
  }

  String _calculateAge() {
    final now = DateTime.now();
    final age = now.difference(_patient.birthDate);

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getAppointmentStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  Color _getAppointmentStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppTheme.warningColor;
      case AppointmentStatus.confirmed:
        return AppTheme.primaryColor;
      case AppointmentStatus.inProgress:
        return AppTheme.accentColor;
      case AppointmentStatus.completed:
        return AppTheme.successColor;
      case AppointmentStatus.cancelled:
        return AppTheme.errorColor;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }

  IconData _getPetIcon() {
    switch (_patient.species.toLowerCase()) {
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
    switch (_patient.species.toLowerCase()) {
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
