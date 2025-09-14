import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Appointment _appointment;
  final TextEditingController _notesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _notesController.text = _appointment.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Appointment Details', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Appointment')),
                  const PopupMenuItem(value: 'cancel', child: Text('Cancel Appointment')),
                  const PopupMenuItem(value: 'complete', child: Text('Mark Complete')),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(),
                const SizedBox(height: 24),
                _buildPetInfo(),
                const SizedBox(height: 24),
                _buildOwnerInfo(),
                const SizedBox(height: 24),
                _buildAppointmentInfo(),
                const SizedBox(height: 24),
                _buildMedicalHistory(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 24),
                _buildActionButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: _getStatusColor().withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: AppTheme.bodyText1.copyWith(color: _getStatusColor(), fontWeight: FontWeight.w600),
                ),
                Text('Appointment Status', style: AppTheme.caption.copyWith(color: _getStatusColor().withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pet Information', style: AppTheme.headline2),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(Icons.pets, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_appointment.petName, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Species: ${_appointment.petSpecies}',
                      style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                    Text(
                      'Breed: ${_appointment.petBreed}',
                      style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondaryColor),
                onPressed: () => Navigator.pushNamed(context, '/patient-detail', arguments: _appointment.petId),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo() {
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
                  Text(_appointment.petOwnerName, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, color: AppTheme.textSecondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(_appointment.contactNumber, style: AppTheme.bodyText2),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, color: AppTheme.textSecondaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(_appointment.contactEmail, style: AppTheme.bodyText2),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appointment Details', style: AppTheme.headline2),
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
              _buildInfoRow('Date & Time', _formatDateTime()),
              const SizedBox(height: 12),
              _buildInfoRow('Service Type', _appointment.serviceType),
              const SizedBox(height: 12),
              _buildInfoRow('Duration', '${_appointment.durationMinutes} minutes'),
              const SizedBox(height: 12),
              _buildInfoRow('Location', _appointment.clinicName),
              if (_appointment.price != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow('Price', '\$${_appointment.price!.toStringAsFixed(2)}'),
              ],
            ],
          ),
        ),
      ],
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

  Widget _buildMedicalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Medical History', style: AppTheme.headline2),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/medical-history', arguments: _appointment.petId),
              child: Text(
                'View All',
                style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Text(
            'No recent medical records found.',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Notes', style: AppTheme.headline2),
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isEditing)
          Column(
            children: [
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add notes about this appointment...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _notesController.text = _appointment.notes ?? '';
                      });
                    },
                    child: Text('Cancel', style: AppTheme.button.copyWith(color: AppTheme.textSecondaryColor)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveNotes,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                    child: Text('Save', style: AppTheme.button.copyWith(color: Colors.white)),
                  ),
                ],
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              _appointment.notes ?? 'No notes added.',
              style: AppTheme.bodyText2.copyWith(
                color: _appointment.notes != null ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (_appointment.status == AppointmentStatus.pending)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _updateAppointmentStatus(AppointmentStatus.confirmed),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: Text('Confirm Appointment', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        if (_appointment.status == AppointmentStatus.confirmed)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateAppointmentStatus(AppointmentStatus.inProgress),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryColor)),
                  child: Text('Start Appointment', style: AppTheme.button.copyWith(color: AppTheme.primaryColor)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateAppointmentStatus(AppointmentStatus.completed),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                  child: Text('Mark Complete', style: AppTheme.button.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        if (_appointment.status == AppointmentStatus.inProgress)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _updateAppointmentStatus(AppointmentStatus.completed),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
              child: Text('Mark Complete', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/add-medical-record', arguments: _appointment),
            style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.accentColor)),
            child: Text('Add Medical Record', style: AppTheme.button.copyWith(color: AppTheme.accentColor)),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit appointment screen
        break;
      case 'cancel':
        _showCancelConfirmationDialog();
        break;
      case 'complete':
        _updateAppointmentStatus(AppointmentStatus.completed);
        break;
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Appointment', style: AppTheme.headline2),
        content: Text('Are you sure you want to cancel this appointment?', style: AppTheme.bodyText2),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No', style: AppTheme.button.copyWith(color: AppTheme.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateAppointmentStatus(AppointmentStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text('Yes, Cancel', style: AppTheme.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateAppointmentStatus(AppointmentStatus status) {
    final provider = context.read<AppClinicProvider>();
    provider.updateAppointmentStatus(_appointment.id, status);

    setState(() {
      _appointment = _appointment.copyWith(status: status);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Appointment status updated to ${_getStatusText().toLowerCase()}',
          style: TextStyle(color: AppTheme.surfaceColor),
        ),
        backgroundColor: _getStatusColor(),
      ),
    );
  }

  void _saveNotes() {
    // TODO: Save notes to backend
    setState(() {
      _isEditing = false;
      _appointment = _appointment.copyWith(notes: _notesController.text);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notes saved successfully', style: TextStyle(color: AppTheme.surfaceColor)),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  String _formatDateTime() {
    final date = '${_appointment.dateTime.day}/${_appointment.dateTime.month}/${_appointment.dateTime.year}';
    final time =
        '${_appointment.dateTime.hour.toString().padLeft(2, '0')}:${_appointment.dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }

  String _getStatusText() {
    switch (_appointment.status) {
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

  Color _getStatusColor() {
    switch (_appointment.status) {
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

  IconData _getStatusIcon() {
    switch (_appointment.status) {
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.inProgress:
        return Icons.play_circle;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
      case AppointmentStatus.noShow:
        return Icons.person_off;
    }
  }
}
