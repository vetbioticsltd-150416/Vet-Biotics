import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'clinic_detail_screen.dart';

class ClinicListScreen extends StatefulWidget {
  const ClinicListScreen({super.key});

  @override
  State<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends State<ClinicListScreen> {
  List<Clinic> _clinics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();
    final clinics = await databaseProvider.getAllClinics() as List<Clinic>;

    setState(() {
      _clinics = clinics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý phòng khám'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddClinicDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Thêm phòng khám',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clinics.isEmpty
          ? _buildEmptyState()
          : _buildClinicsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Chưa có phòng khám nào', style: AppTheme.headline3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Thêm phòng khám đầu tiên để bắt đầu quản lý',
            style: AppTheme.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddClinicDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Thêm phòng khám'),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicsList() {
    return RefreshIndicator(
      onRefresh: _loadClinics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _clinics.length,
        itemBuilder: (context, index) {
          final clinic = _clinics[index];
          return _buildClinicCard(clinic);
        },
      ),
    );
  }

  Widget _buildClinicCard(Clinic clinic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClinicDetailScreen(clinicId: clinic.id!))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: clinic.logoUrl != null ? NetworkImage(clinic.logoUrl!) : null,
                    child: clinic.logoUrl == null ? Icon(Icons.business, color: AppTheme.primaryColor) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(clinic.name, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          clinic.address ?? 'Chưa cập nhật địa chỉ',
                          style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: clinic.status == ClinicStatus.active
                          ? Colors.green.withOpacity(0.1)
                          : clinic.status == ClinicStatus.inactive
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      clinic.status.displayName,
                      style: TextStyle(
                        color: clinic.status == ClinicStatus.active
                            ? Colors.green
                            : clinic.status == ClinicStatus.inactive
                            ? Colors.orange
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (clinic.phone != null) ...[
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(clinic.phone!, style: AppTheme.caption),
                    const SizedBox(width: 16),
                  ],
                  if (clinic.email != null) ...[
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(clinic.email!, style: AppTheme.caption),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatItem('Lịch hẹn', '0'), // TODO: Get real stats
                  Container(width: 1, height: 20, color: AppTheme.borderColor),
                  _buildStatItem('Thú cưng', '0'), // TODO: Get real stats
                  Container(width: 1, height: 20, color: AppTheme.borderColor),
                  _buildStatItem('Doanh thu', '0đ'), // TODO: Get real stats
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddClinicDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm phòng khám mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên phòng khám *', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên phòng khám';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên phòng khám')));
                return;
              }

              // TODO: Get current user ID
              const ownerId = 'admin_user_id'; // Mock admin user ID

              final clinic = Clinic(
                name: nameController.text.trim(),
                address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                ownerId: ownerId,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isActive: true,
              );

              final databaseProvider = context.read<DatabaseProvider>();
              final clinicId = await databaseProvider.createClinic(clinic);

              Navigator.of(context).pop();

              if (clinicId != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã tạo phòng khám thành công')));
                _loadClinics();
              }
            },
            child: const Text('Tạo phòng khám'),
          ),
        ],
      ),
    );
  }
}

