import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';
import '../medical/medical_history_screen.dart';
import '../widgets/pet_alerts_widget.dart';
import 'weight_tracking_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Pet? _pet;
  PetMedicalSummary? _medicalSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPetData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPetData() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    // Load pet details
    final pet = await databaseProvider.getPet(widget.petId) as Pet?;
    final summary = await databaseProvider.getPetMedicalSummary(widget.petId) as PetMedicalSummary?;

    setState(() {
      _pet = pet;
      _medicalSummary = summary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thú cưng')),
        body: const Center(child: Text('Không tìm thấy thú cưng')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildPetHeader()),
            actions: [IconButton(onPressed: () => _showPetOptions(context), icon: const Icon(Icons.more_vert))],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Chi tiết'),
                Tab(text: 'Lịch sử'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [_buildOverviewTab(), _buildDetailsTab(), _buildHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildPetHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primaryColor.withOpacity(0.8), AppTheme.primaryColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pet Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: _pet!.primaryPhotoUrl != null ? NetworkImage(_pet!.primaryPhotoUrl!) : null,
            child: _pet!.primaryPhotoUrl == null
                ? Icon(_getSpeciesIcon(_pet!.species), size: 40, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(height: 16),

          // Pet Name and Age
          Text(_pet!.name, style: AppTheme.headline1.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            '${_pet!.species.displayName} • ${_pet!.ageString}',
            style: AppTheme.bodyText1.copyWith(color: Colors.white.withOpacity(0.9)),
          ),

          // Status Badge
          if (_pet!.status != PetStatus.active) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: Text(_pet!.status.displayName, style: AppTheme.caption.copyWith(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadPetData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Status Card
            _buildHealthStatusCard(),

            const SizedBox(height: 16),

            // Pet Alerts
            PetAlertsWidget(pet: _pet!, medicalSummary: _medicalSummary),

            const SizedBox(height: 24),

            // Quick Actions
            Text('Quick Actions', style: AppTheme.headline2),
            const SizedBox(height: 16),
            _buildQuickActions(),

            const SizedBox(height: 24),

            // Recent Activity
            Text('Hoạt động gần đây', style: AppTheme.headline2),
            const SizedBox(height: 16),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    final hasAllergies = _pet!.hasAllergies;
    final isOnMedication = _pet!.isOnMedication;
    final needsVaccination = _medicalSummary?.needsVaccination ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: AppTheme.successColor, size: 24),
                const SizedBox(width: 8),
                Text('Tình trạng sức khỏe', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),

            // Health indicators
            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Cân nặng',
                    _pet!.weight != null ? '${_pet!.weight} kg' : 'Chưa cập nhật',
                    _pet!.weight != null ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.borderColor),
                Expanded(
                  child: _buildHealthIndicator(
                    'Dị ứng',
                    hasAllergies ? 'Có' : 'Không',
                    hasAllergies ? Colors.orange : Colors.green,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.borderColor),
                Expanded(
                  child: _buildHealthIndicator(
                    'Thuốc',
                    isOnMedication ? 'Đang dùng' : 'Không',
                    isOnMedication ? Colors.blue : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Tiêm phòng',
                    needsVaccination ? 'Cần tiêm' : 'Đã tiêm',
                    needsVaccination ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),

            // Current medications
            if (_medicalSummary?.currentMedications.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text('Thuốc hiện tại:', style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _medicalSummary!.currentMedications.map((med) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(med, style: AppTheme.caption),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTheme.caption, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyText2.copyWith(color: color, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Lịch sử y tế',
            Icons.medical_services,
            AppTheme.accentColor,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MedicalHistoryScreen(petId: widget.petId, petName: _pet!.name),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            'Theo dõi cân nặng',
            Icons.monitor_weight,
            AppTheme.warningColor,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WeightTrackingScreen(petId: widget.petId, petName: _pet!.name),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton('Chỉnh sửa', Icons.edit, AppTheme.primaryColor, () {
            // TODO: Navigate to edit pet screen
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
          }),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.caption.copyWith(color: color, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Mock recent activities - in real app this would come from database
    final activities = [
      {'type': 'visit', 'description': 'Khám tổng quát', 'date': DateTime.now().subtract(const Duration(days: 7))},
      {
        'type': 'vaccination',
        'description': 'Tiêm phòng dại',
        'date': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'type': 'medication',
        'description': 'Thuốc kháng sinh',
        'date': DateTime.now().subtract(const Duration(days: 45)),
      },
    ];

    return Column(
      children: activities.map((activity) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getActivityColor(activity['type'] as String).withOpacity(0.1),
              child: Icon(
                _getActivityIcon(activity['type'] as String),
                color: _getActivityColor(activity['type'] as String),
                size: 20,
              ),
            ),
            title: Text(activity['description'] as String),
            subtitle: Text(
              '${(activity['date'] as DateTime).day}/${(activity['date'] as DateTime).month}/${(activity['date'] as DateTime).year}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          Text('Thông tin cơ bản', style: AppTheme.headline2),
          const SizedBox(height: 16),
          _buildInfoCard([
            _buildInfoRow('Tên', _pet!.name),
            _buildInfoRow('Loài', _pet!.species.displayName),
            if (_pet!.breed != null) _buildInfoRow('Giống', _pet!.breed!),
            _buildInfoRow('Giới tính', _pet!.gender.displayName),
            if (_pet!.dateOfBirth != null)
              _buildInfoRow(
                'Ngày sinh',
                '${_pet!.dateOfBirth!.day}/${_pet!.dateOfBirth!.month}/${_pet!.dateOfBirth!.year}',
              ),
            if (_pet!.weight != null) _buildInfoRow('Cân nặng', '${_pet!.weight} kg'),
            if (_pet!.color != null) _buildInfoRow('Màu sắc', _pet!.color!),
            if (_pet!.microchipId != null) _buildInfoRow('Microchip', _pet!.microchipId!),
          ]),

          const SizedBox(height: 24),

          // Health Information
          Text('Thông tin sức khỏe', style: AppTheme.headline2),
          const SizedBox(height: 16),
          _buildInfoCard([
            if (_pet!.allergies?.isNotEmpty == true) _buildInfoRow('Dị ứng', _pet!.allergies!.join(', ')),
            if (_pet!.medications?.isNotEmpty == true)
              _buildInfoRow('Thuốc thường dùng', _pet!.medications!.join(', ')),
            _buildInfoRow('Cần tiêm phòng', _medicalSummary?.needsVaccination == true ? 'Có' : 'Không'),
            if (_medicalSummary?.totalVisits != null)
              _buildInfoRow('Tổng số lần khám', '${_medicalSummary!.totalVisits}'),
            if (_medicalSummary?.lastVisitDate != null)
              _buildInfoRow(
                'Khám cuối',
                '${_medicalSummary!.lastVisitDate!.day}/${_medicalSummary!.lastVisitDate!.month}/${_medicalSummary!.lastVisitDate!.year}',
              ),
          ]),

          // Notes
          if (_pet!.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            Text('Ghi chú', style: AppTheme.headline2),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_pet!.notes!, style: AppTheme.bodyText2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return MedicalHistoryScreen(petId: widget.petId, petName: _pet!.name);
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500, color: AppTheme.textSecondaryColor),
            ),
          ),
          Expanded(child: Text(value, style: AppTheme.bodyText2)),
        ],
      ),
    );
  }

  void _showPetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa thông tin'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to edit pet screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Thay đổi ảnh'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement photo picker
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Chia sẻ thông tin'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa thú cưng', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa thú cưng này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePet();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePet() async {
    final databaseProvider = context.read<DatabaseProvider>();
    await databaseProvider.deletePet(widget.petId);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa thú cưng')));

    Navigator.of(context).pop(); // Go back to previous screen
  }

  IconData _getSpeciesIcon(PetSpecies species) {
    switch (species) {
      case PetSpecies.dog:
        return Icons.pets;
      case PetSpecies.cat:
        return Icons.pets;
      case PetSpecies.bird:
        return Icons.flutter_dash;
      case PetSpecies.rabbit:
        return Icons.pets;
      case PetSpecies.hamster:
        return Icons.pets;
      case PetSpecies.fish:
        return Icons.pool;
      case PetSpecies.reptile:
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'visit':
        return Icons.medical_services;
      case 'vaccination':
        return Icons.vaccines;
      case 'medication':
        return Icons.medication;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'visit':
        return AppTheme.primaryColor;
      case 'vaccination':
        return Colors.green;
      case 'medication':
        return Colors.blue;
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
