import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class ClinicDetailScreen extends StatefulWidget {
  final String clinicId;

  const ClinicDetailScreen({super.key, required this.clinicId});

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Clinic? _clinic;
  List<ClinicService> _services = [];
  List<ClinicStaff> _staff = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadClinicData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClinicData() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    final clinic = await databaseProvider.getClinic(widget.clinicId) as Clinic?;
    final services = await databaseProvider.getClinicServices(widget.clinicId) as List<ClinicService>;
    final staff = await databaseProvider.getClinicStaff(widget.clinicId) as List<ClinicStaff>;
    final analytics = await databaseProvider.getClinicAnalytics(widget.clinicId);

    setState(() {
      _clinic = clinic;
      _services = services;
      _staff = staff;
      _analytics = analytics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_clinic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết phòng khám')),
        body: const Center(child: Text('Không tìm thấy phòng khám')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildClinicHeader(),
            ),
            actions: [
              IconButton(
                onPressed: () => _showClinicOptions(context),
                icon: const Icon(Icons.more_vert),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tổng quan'),
                Tab(text: 'Dịch vụ'),
                Tab(text: 'Nhân viên'),
                Tab(text: 'Thống kê'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildServicesTab(),
            _buildStaffTab(),
            _buildAnalyticsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicHeader() {
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
          // Clinic Logo
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: _clinic!.logoUrl != null ? NetworkImage(_clinic!.logoUrl!) : null,
            child: _clinic!.logoUrl == null
                ? Icon(Icons.business, size: 40, color: AppTheme.primaryColor)
                : null,
          ),
          const SizedBox(height: 16),

          // Clinic Name
          Text(
            _clinic!.name,
            style: AppTheme.headline1.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Clinic Address
          if (_clinic!.address != null) ...[
            Text(
              _clinic!.address!,
              style: AppTheme.bodyText1.copyWith(color: Colors.white.withOpacity(0.9)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _clinic!.status.displayName,
              style: AppTheme.caption.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadClinicData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Information
            Text('Thông tin liên hệ', style: AppTheme.headline2),
            const SizedBox(height: 16),
            _buildContactInfo(),

            const SizedBox(height: 24),

            // Quick Stats
            Text('Thống kê nhanh', style: AppTheme.headline2),
            const SizedBox(height: 16),
            _buildQuickStats(),

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

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_clinic!.phone != null) ...[
              ListTile(
                leading: const Icon(Icons.phone, color: AppTheme.primaryColor),
                title: const Text('Điện thoại'),
                subtitle: Text(_clinic!.phone!),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // TODO: Implement phone call
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng gọi điện đang phát triển')),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
            if (_clinic!.email != null) ...[
              ListTile(
                leading: const Icon(Icons.email, color: AppTheme.primaryColor),
                title: const Text('Email'),
                subtitle: Text(_clinic!.email!),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // TODO: Implement email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng gửi email đang phát triển')),
                    );
                  },
                ),
              ),
              const Divider(),
            ],
            if (_clinic!.website != null) ...[
              ListTile(
                leading: const Icon(Icons.web, color: AppTheme.primaryColor),
                title: const Text('Website'),
                subtitle: Text(_clinic!.website!),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () {
                    // TODO: Implement website opening
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tính năng mở website đang phát triển')),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Lịch hẹn',
            '${_analytics['appointmentsThisMonth'] ?? 0}',
            'Tháng này',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Thú cưng',
            '${_analytics['totalPets'] ?? 0}',
            'Tổng số',
            Icons.pets,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Doanh thu',
            '${(_analytics['revenue'] ?? 0) ~/ 1000}k',
            'VNĐ',
            Icons.attach_money,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headline2.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(title, style: AppTheme.caption, textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    // Mock recent activities
    final activities = [
      {'type': 'appointment', 'description': 'Lịch hẹn mới với Bella', 'time': '2 giờ trước'},
      {'type': 'service', 'description': 'Thêm dịch vụ Tiêm phòng', 'time': '1 ngày trước'},
      {'type': 'staff', 'description': 'Thêm nhân viên Dr. Nguyễn', 'time': '3 ngày trước'},
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
            subtitle: Text(activity['time'] as String),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesTab() {
    return Scaffold(
      body: _services.isEmpty ? _buildEmptyServices() : _buildServicesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyServices() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Chưa có dịch vụ nào', style: AppTheme.headline3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Thêm dịch vụ đầu tiên cho phòng khám',
            style: AppTheme.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddServiceDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Thêm dịch vụ'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(service.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.description != null) Text(service.description!),
                Text('${service.price.toInt()} VNĐ - ${service.durationMinutes} phút'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditServiceDialog(context, service),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteServiceDialog(context, service),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStaffTab() {
    return Scaffold(
      body: _staff.isEmpty ? _buildEmptyStaff() : _buildStaffList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStaffDialog(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildEmptyStaff() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Chưa có nhân viên nào', style: AppTheme.headline3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Thêm nhân viên đầu tiên cho phòng khám',
            style: AppTheme.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStaffDialog(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Thêm nhân viên'),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staff.length,
      itemBuilder: (context, index) {
        final staffMember = _staff[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(
                staffMember.role == 'veterinarian' ? Icons.medical_services : Icons.admin_panel_settings,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(staffMember.role), // TODO: Get user name from userId
            subtitle: Text('Role: ${staffMember.role}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditStaffDialog(context, staffMember),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteStaffDialog(context, staffMember),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return RefreshIndicator(
      onRefresh: _loadClinicData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thống kê phòng khám', style: AppTheme.headline2),
            const SizedBox(height: 16),

            // Analytics Cards
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Tổng lịch hẹn',
                    '${_analytics['totalAppointments'] ?? 0}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Lịch hẹn tháng này',
                    '${_analytics['appointmentsThisMonth'] ?? 0}',
                    Icons.today,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Tổng thú cưng',
                    '${_analytics['totalPets'] ?? 0}',
                    Icons.pets,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Bệnh án',
                    '${_analytics['totalMedicalRecords'] ?? 0}',
                    Icons.medical_services,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Revenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doanh thu ước tính', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      '${(_analytics['revenue'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                      style: AppTheme.headline2.copyWith(color: AppTheme.successColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dựa trên số lượng lịch hẹn',
                      style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.headline3.copyWith(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(title, style: AppTheme.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showClinicOptions(BuildContext context) {
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
                // TODO: Navigate to edit clinic screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt phòng khám'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to clinic settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa phòng khám', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteClinicDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm dịch vụ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên dịch vụ *'),
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tên dịch vụ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Giá (VNĐ) *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: 'Thời gian (phút) *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty || durationController.text.isEmpty) {
                return;
              }

              final service = ClinicService(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                price: double.parse(priceController.text),
                durationMinutes: int.parse(durationController.text),
              );

              final databaseProvider = context.read<DatabaseProvider>();
              await databaseProvider.createClinicService(service);

              Navigator.of(context).pop();
              _loadClinicData();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhân viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: roleController,
              decoration: const InputDecoration(labelText: 'Vai trò *'),
            ),
            // TODO: Add user selection dropdown
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (roleController.text.isEmpty) return;

              // Mock user ID - in real app would select from user list
              const userId = 'mock_user_id';

              final staff = ClinicStaff(
                userId: userId,
                clinicId: widget.clinicId,
                role: roleController.text.trim(),
              );

              final databaseProvider = context.read<DatabaseProvider>();
              await databaseProvider.addClinicStaff(staff);

              Navigator.of(context).pop();
              _loadClinicData();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteClinicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa phòng khám này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteClinic();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClinic() async {
    final databaseProvider = context.read<DatabaseProvider>();
    await databaseProvider.deleteClinic(widget.clinicId);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa phòng khám'));
    Navigator.of(context).pop(); // Go back to clinic list
  }

  // Placeholder methods for edit/delete dialogs
  void _showEditServiceDialog(BuildContext context, ClinicService service) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng chỉnh sửa dịch vụ đang phát triển')));
  }

  void _showDeleteServiceDialog(BuildContext context, ClinicService service) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng xóa dịch vụ đang phát triển')));
  }

  void _showEditStaffDialog(BuildContext context, ClinicStaff staff) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng chỉnh sửa nhân viên đang phát triển')));
  }

  void _showDeleteStaffDialog(BuildContext context, ClinicStaff staff) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng xóa nhân viên đang phát triển')));
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'appointment':
        return Colors.blue;
      case 'service':
        return Colors.green;
      case 'staff':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'service':
        return Icons.medical_services;
      case 'staff':
        return Icons.person;
      default:
        return Icons.info;
    }
  }
}

