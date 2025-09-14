import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';
import '../../widgets/appointment_card.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  AppointmentStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        return Scaffold(
          appBar: AppBar(
            title: Text('Appointments', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Pending'),
              ],
              labelStyle: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
              unselectedLabelStyle: AppTheme.bodyText2,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
            ),
            actions: [
              IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.pushNamed(context, '/new-appointment'),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentList(provider.todayAppointments),
                    _buildAppointmentList(provider.upcomingAppointments),
                    _buildAppointmentList(provider.pendingAppointments),
                  ],
                ),
              ),
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
          hintText: 'Search appointments...',
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

  Widget _buildAppointmentList(List<Appointment> appointments) {
    final filteredAppointments = _filterAppointments(appointments);

    if (filteredAppointments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return AppointmentCard(
          appointment: appointment,
          onTap: () => Navigator.pushNamed(context, '/appointment-detail', arguments: appointment),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: AppTheme.textHintColor),
          const SizedBox(height: 24),
          Text('No appointments found', style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            'Appointments will appear here when scheduled',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/new-appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
              child: Text('Schedule Appointment', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<Appointment> _filterAppointments(List<Appointment> appointments) {
    return appointments.where((appointment) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          appointment.petName.toLowerCase().contains(_searchQuery) ||
          appointment.petOwnerName.toLowerCase().contains(_searchQuery) ||
          appointment.serviceType.toLowerCase().contains(_searchQuery);

      // Status filter
      final matchesStatus = _statusFilter == null || appointment.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Filter Appointments', style: AppTheme.headline2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppointmentStatus.values.map((status) {
                  return FilterChip(
                    label: Text(_getStatusDisplayName(status)),
                    selected: _statusFilter == status,
                    onSelected: (selected) {
                      setState(() {
                        _statusFilter = selected ? status : null;
                      });
                      this.setState(() {});
                    },
                    backgroundColor: AppTheme.surfaceColor,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = null;
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

  String _getStatusDisplayName(AppointmentStatus status) {
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
}
