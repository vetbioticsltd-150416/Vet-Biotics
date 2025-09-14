import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

import 'add_medical_record_screen.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const MedicalHistoryScreen({super.key, required this.petId, required this.petName});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<MedicalRecord> _medicalRecords = [];
  List<VaccinationRecord> _vaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMedicalData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedicalData() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    // Load medical records
    final records = await databaseProvider.getPetMedicalRecords(widget.petId) as List<MedicalRecord>;

    // Load vaccinations
    final vaccinations = await databaseProvider.getPetVaccinations(widget.petId) as List<VaccinationRecord>;

    setState(() {
      _medicalRecords = records;
      _vaccinations = vaccinations;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử y tế - ${widget.petName}'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => AddMedicalRecordScreen(petId: widget.petId)));
              // Reload data when returning
              _loadMedicalData();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Thêm bản ghi y tế',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Lịch sử'),
            Tab(text: 'Tiêm phòng'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildOverviewTab(), _buildHistoryTab(), _buildVaccinationsTab()],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final recentRecords = _medicalRecords.take(3).toList();
    final upcomingVaccinations = _vaccinations
        .where((v) => v.nextDueDate?.isAfter(DateTime.now()) ?? false)
        .take(3)
        .toList();

    return RefreshIndicator(
      onRefresh: _loadMedicalData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Summary
            Text('Tóm tắt sức khỏe', style: AppTheme.headline2),
            const SizedBox(height: 16),
            _buildHealthSummary(),

            const SizedBox(height: 24),

            // Recent Medical Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lịch sử gần đây', style: AppTheme.headline2),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: Text('Xem tất cả', style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recentRecords.map(_buildMedicalRecordCard),

            const SizedBox(height: 24),

            // Upcoming Vaccinations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tiêm phòng sắp tới', style: AppTheme.headline2),
                TextButton(
                  onPressed: () => _tabController.animateTo(2),
                  child: Text('Xem tất cả', style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingVaccinations.map(_buildVaccinationCard),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_medicalRecords.isEmpty) {
      return _buildEmptyState(
        'Chưa có bản ghi y tế',
        'Các bản ghi y tế sẽ xuất hiện ở đây sau khi thú cưng thăm khám.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedicalData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _medicalRecords.length,
        itemBuilder: (context, index) {
          return _buildMedicalRecordCard(_medicalRecords[index]);
        },
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    if (_vaccinations.isEmpty) {
      return _buildEmptyState(
        'Chưa có lịch tiêm phòng',
        'Lịch tiêm phòng sẽ xuất hiện ở đây sau khi thú cưng được tiêm.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedicalData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vaccinations.length,
        itemBuilder: (context, index) {
          return _buildVaccinationCard(_vaccinations[index]);
        },
      ),
    );
  }

  Widget _buildHealthSummary() {
    final lastCheckup = _medicalRecords.isNotEmpty ? _medicalRecords.first : null;
    final nextVaccination = _vaccinations.where((v) => v.nextDueDate?.isAfter(DateTime.now()) ?? false).firstOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.health_and_safety, color: AppTheme.successColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tình trạng sức khỏe', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        'Tốt - Khám định kỳ đều đặn',
                        style: AppTheme.bodyText2.copyWith(color: AppTheme.successColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Khám cuối',
                    lastCheckup != null
                        ? '${lastCheckup.recordDate.day}/${lastCheckup.recordDate.month}/${lastCheckup.recordDate.year}'
                        : 'Chưa có',
                    Icons.calendar_today,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.borderColor),
                Expanded(
                  child: _buildSummaryItem(
                    'Tiêm tiếp theo',
                    nextVaccination?.nextDueDate != null
                        ? '${nextVaccination!.nextDueDate!.day}/${nextVaccination.nextDueDate!.month}/${nextVaccination.nextDueDate!.year}'
                        : 'Không có',
                    Icons.vaccines,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption, textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRecordTypeColor(record.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.type.displayName,
                    style: TextStyle(
                      color: _getRecordTypeColor(record.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (record.symptoms?.isNotEmpty == true) ...[
              Text('Triệu chứng:', style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(record.symptoms!, style: AppTheme.bodyText2),
              const SizedBox(height: 8),
            ],

            if (record.diagnosis?.isNotEmpty == true) ...[
              Text('Chẩn đoán:', style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(record.diagnosis!, style: AppTheme.bodyText2),
              const SizedBox(height: 8),
            ],

            if (record.treatment?.isNotEmpty == true) ...[
              Text('Điều trị:', style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(record.treatment!, style: AppTheme.bodyText2),
            ],

            if (record.weight != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.monitor_weight, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Cân nặng: ${record.weight} kg', style: AppTheme.bodyText2),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationCard(VaccinationRecord vaccination) {
    final isOverdue = vaccination.isOverdue;
    final isUpcoming = vaccination.nextDueDate?.isAfter(DateTime.now()) ?? false;

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
                    color: isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : isUpcoming
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverdue
                        ? 'Quá hạn'
                        : isUpcoming
                        ? 'Sắp đến'
                        : 'Đã tiêm',
                    style: TextStyle(
                      color: isOverdue
                          ? Colors.red
                          : isUpcoming
                          ? Colors.orange
                          : Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${vaccination.vaccinationDate.day}/${vaccination.vaccinationDate.month}/${vaccination.vaccinationDate.year}',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(vaccination.vaccineName, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            if (vaccination.nextDueDate != null) ...[
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Tiêm tiếp theo: ${vaccination.nextDueDate!.day}/${vaccination.nextDueDate!.month}/${vaccination.nextDueDate!.year}',
                    style: AppTheme.bodyText2,
                  ),
                ],
              ),
            ],

            if (vaccination.batchNumber?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.tag, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Lô: ${vaccination.batchNumber}', style: AppTheme.bodyText2),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: AppTheme.headline3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => AddMedicalRecordScreen(petId: widget.petId)));
              _loadMedicalData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm bản ghi'),
          ),
        ],
      ),
    );
  }

  Color _getRecordTypeColor(MedicalRecordType type) {
    switch (type) {
      case MedicalRecordType.emergency:
        return Colors.red;
      case MedicalRecordType.surgery:
        return Colors.orange;
      case MedicalRecordType.vaccination:
        return Colors.blue;
      case MedicalRecordType.laboratory:
        return Colors.purple;
      case MedicalRecordType.imaging:
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }
}

