import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'book_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    final allAppointments = await databaseProvider.getUserAppointments() as List<Appointment>;
    final now = DateTime.now();

    setState(() {
      _upcomingAppointments = allAppointments.where((appointment) => appointment.scheduledDate.isAfter(now)).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      _pastAppointments = allAppointments.where((appointment) => appointment.scheduledDate.isBefore(now)).toList()
        ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

      _isLoading = false;
    });
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: const Text('Bạn có chắc muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final databaseProvider = context.read<DatabaseProvider>();
      await databaseProvider.cancelAppointment(appointmentId);
      await _loadAppointments();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy lịch hẹn')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookAppointmentScreen()));
              // Reload appointments when returning from booking
              _loadAppointments();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Đặt lịch hẹn',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sắp tới'),
            Tab(text: 'Đã qua'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_upcomingAppointments, isUpcoming: true),
                _buildAppointmentsList(_pastAppointments, isUpcoming: false),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isUpcoming ? Icons.calendar_today : Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'Không có lịch hẹn sắp tới' : 'Không có lịch hẹn đã qua',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (isUpcoming)
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookAppointmentScreen()));
                  _loadAppointments();
                },
                icon: const Icon(Icons.add),
                label: const Text('Đặt lịch hẹn'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment, isUpcoming: isUpcoming);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, {required bool isUpcoming}) {
    final databaseProvider = context.read<DatabaseProvider>();
    final clinics = databaseProvider.status == DatabaseStatus.success ? [] : []; // TODO: Load clinics

    // Mock clinic name for now
    final clinicName = 'Phòng khám ABC'; // TODO: Get real clinic name

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: appointment.status == AppointmentStatus.scheduled
                        ? Colors.blue.withOpacity(0.1)
                        : appointment.status == AppointmentStatus.completed
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment.status.displayName,
                    style: TextStyle(
                      color: appointment.status == AppointmentStatus.scheduled
                          ? Colors.blue
                          : appointment.status == AppointmentStatus.completed
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  appointment.type.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(clinicName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${appointment.scheduledDate.day}/${appointment.scheduledDate.month}/${appointment.scheduledDate.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${appointment.scheduledDate.hour.toString().padLeft(2, '0')}:${appointment.scheduledDate.minute.toString().padLeft(2, '0')} - ${appointment.endDate.hour.toString().padLeft(2, '0')}:${appointment.endDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Ghi chú: ${appointment.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],

            if (isUpcoming && appointment.canBeCancelled) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _cancelAppointment(appointment.id!),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Hủy lịch'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

