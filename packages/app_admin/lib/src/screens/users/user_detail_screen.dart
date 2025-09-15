import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with SingleTickerProviderStateMixin {
  UserProfile? _userProfile;
  List<UserActivity> _activities = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    final userProfile = await databaseProvider.getUserProfile(widget.userId) as UserProfile?;
    if (userProfile != null) {
      final activities = await databaseProvider.getUserActivities(widget.userId) as List<UserActivity>;
      setState(() {
        _userProfile = userProfile;
        _activities = activities;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết người dùng')),
        body: const Center(child: Text('Không tìm thấy người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile!.fullName),
        elevation: 0,
        actions: [IconButton(onPressed: () => _showUserOptions(context), icon: const Icon(Icons.more_vert))],
      ),
      body: Column(
        children: [
          // User header
          _buildUserHeader(),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Thông tin'),
              Tab(text: 'Hoạt động'),
              Tab(text: 'Thiết lập'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildProfileTab(), _buildActivityTab(), _buildSettingsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: _getRoleColor(_userProfile!.role).withOpacity(0.1),
            backgroundImage: _userProfile!.avatarUrl != null ? NetworkImage(_userProfile!.avatarUrl!) : null,
            child: _userProfile!.avatarUrl == null
                ? Icon(_getRoleIcon(_userProfile!.role), size: 32, color: _getRoleColor(_userProfile!.role))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userProfile!.fullName, style: AppTheme.headline2.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_userProfile!.email, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(_userProfile!.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userProfile!.role.displayName,
                        style: TextStyle(
                          color: _getRoleColor(_userProfile!.role),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _userProfile!.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userProfile!.isActive ? 'Hoạt động' : 'Không hoạt động',
                        style: TextStyle(
                          color: _userProfile!.isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic information
          Text('Thông tin cơ bản', style: AppTheme.headline2),
          const SizedBox(height: 16),
          _buildInfoCard([
            _buildInfoRow('Họ tên', _userProfile!.displayName ?? 'Chưa cập nhật'),
            _buildInfoRow('Email', _userProfile!.email),
            _buildInfoRow('Số điện thoại', _userProfile!.phoneNumber ?? 'Chưa cập nhật'),
            if (_userProfile!.dateOfBirth != null)
              _buildInfoRow(
                'Ngày sinh',
                '${_userProfile!.dateOfBirth!.day}/${_userProfile!.dateOfBirth!.month}/${_userProfile!.dateOfBirth!.year}',
              ),
            _buildInfoRow('Tuổi', _userProfile!.age?.toString() ?? 'Chưa cập nhật'),
            _buildInfoRow('Giới tính', _userProfile!.gender ?? 'Chưa cập nhật'),
            _buildInfoRow('Địa chỉ', _userProfile!.address ?? 'Chưa cập nhật'),
          ]),

          const SizedBox(height: 24),

          // Account information
          Text('Thông tin tài khoản', style: AppTheme.headline2),
          const SizedBox(height: 16),
          _buildInfoCard([
            _buildInfoRow('ID người dùng', _userProfile!.userId),
            _buildInfoRow('Vai trò', _userProfile!.role.displayName),
            if (_userProfile!.clinicId != null) _buildInfoRow('Phòng khám', _userProfile!.clinicId!),
            _buildInfoRow('Email đã xác minh', _userProfile!.isEmailVerified ? 'Có' : 'Không'),
            _buildInfoRow('Trạng thái', _userProfile!.isActive ? 'Hoạt động' : 'Không hoạt động'),
            if (_userProfile!.lastLoginAt != null)
              _buildInfoRow('Đăng nhập cuối', _formatDateTime(_userProfile!.lastLoginAt!)),
            _buildInfoRow('Ngày tạo', _formatDateTime(_userProfile!.createdAt)),
            _buildInfoRow('Ngày cập nhật', _formatDateTime(_userProfile!.updatedAt)),
          ]),

          const SizedBox(height: 24),

          // Bio
          if (_userProfile!.bio != null && _userProfile!.bio!.isNotEmpty) ...[
            Text('Tiểu sử', style: AppTheme.headline2),
            const SizedBox(height: 16),
            Card(
              child: Padding(padding: const EdgeInsets.all(16), child: Text(_userProfile!.bio!)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Chưa có hoạt động nào', style: AppTheme.headline3),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityCard(activity);
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role management
          Text('Quản lý vai trò', style: AppTheme.headline2),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vai trò hiện tại: ${_userProfile!.role.displayName}'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: UserRole.values.map((role) {
                      final isSelected = _userProfile!.role == role;
                      return ChoiceChip(
                        label: Text(role.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected && !isSelected) {
                            _changeUserRole(role);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Account status
          Text('Trạng thái tài khoản', style: AppTheme.headline2),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userProfile!.isActive ? 'Tài khoản đang hoạt động' : 'Tài khoản đã bị vô hiệu hóa',
                          style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userProfile!.isActive
                              ? 'Người dùng có thể đăng nhập và sử dụng ứng dụng'
                              : 'Người dùng không thể đăng nhập vào ứng dụng',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  Switch(value: _userProfile!.isActive, onChanged: (value) => _toggleUserStatus(value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
            child: Text(label, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: AppTheme.bodyText2)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(UserActivity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActivityColor(activity.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getActivityIcon(activity.type), color: _getActivityColor(activity.type)),
        ),
        title: Text(activity.action),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.description != null) Text(activity.description!),
            Text(
              _formatDateTime(activity.createdAt),
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        isThreeLine: activity.description != null,
      ),
    );
  }

  void _showUserOptions(BuildContext context) {
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
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => UserProfileEditScreen(userId: widget.userId)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Gửi email'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Send email to user
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tính năng gửi email đang phát triển')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Gửi tin nhắn'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Send message to user
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tính năng gửi tin nhắn đang phát triển')));
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: _userProfile!.isActive ? Colors.red : Colors.green),
              title: Text(_userProfile!.isActive ? 'Vô hiệu hóa tài khoản' : 'Kích hoạt tài khoản'),
              onTap: () {
                Navigator.of(context).pop();
                _toggleUserStatus(!_userProfile!.isActive);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeUserRole(UserRole newRole) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay đổi vai trò'),
        content: Text('Bạn có chắc muốn thay đổi vai trò của người dùng này thành "${newRole.displayName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xác nhận')),
        ],
      ),
    );

    if (confirmed == true) {
      final databaseProvider = context.read<DatabaseProvider>();
      await databaseProvider.updateUserRole(widget.userId, newRole);

      // Log activity
      final activity = UserActivity(
        userId: 'admin', // Current admin user
        type: ActivityType.update,
        action: 'Cập nhật vai trò người dùng',
        description: 'Thay đổi vai trò từ ${_userProfile!.role.displayName} thành ${newRole.displayName}',
        relatedEntityId: widget.userId,
        relatedEntityType: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );
      await databaseProvider.logUserActivity(activity);

      _loadUserData();
    }
  }

  Future<void> _toggleUserStatus(bool activate) async {
    final databaseProvider = context.read<DatabaseProvider>();

    if (activate) {
      await databaseProvider.reactivateUser(widget.userId);
    } else {
      await databaseProvider.deactivateUser(widget.userId);
    }

    // Log activity
    final activity = UserActivity(
      userId: 'admin', // Current admin user
      type: ActivityType.update,
      action: activate ? 'Kích hoạt tài khoản' : 'Vô hiệu hóa tài khoản',
      relatedEntityId: widget.userId,
      relatedEntityType: 'user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    await databaseProvider.logUserActivity(activity);

    _loadUserData();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Colors.red;
      case UserRole.clinicAdmin:
        return Colors.orange;
      case UserRole.veterinarian:
        return Colors.blue;
      case UserRole.receptionist:
        return Colors.green;
      case UserRole.customer:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.clinicAdmin:
        return Icons.business;
      case UserRole.veterinarian:
        return Icons.medical_services;
      case UserRole.receptionist:
        return Icons.receipt;
      case UserRole.customer:
        return Icons.person;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.login:
        return Colors.green;
      case ActivityType.logout:
        return Colors.grey;
      case ActivityType.create:
        return Colors.blue;
      case ActivityType.update:
        return Colors.orange;
      case ActivityType.delete:
        return Colors.red;
      case ActivityType.view:
        return Colors.purple;
      case ActivityType.export:
        return Colors.teal;
      case ActivityType.import:
        return Colors.indigo;
      case ActivityType.payment:
        return Colors.amber;
      case ActivityType.appointment:
        return Colors.cyan;
      case ActivityType.medical:
        return Colors.pink;
      case ActivityType.system:
        return Colors.brown;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.login:
        return Icons.login;
      case ActivityType.logout:
        return Icons.logout;
      case ActivityType.create:
        return Icons.add;
      case ActivityType.update:
        return Icons.edit;
      case ActivityType.delete:
        return Icons.delete;
      case ActivityType.view:
        return Icons.visibility;
      case ActivityType.export:
        return Icons.download;
      case ActivityType.import:
        return Icons.upload;
      case ActivityType.payment:
        return Icons.payment;
      case ActivityType.appointment:
        return Icons.calendar_today;
      case ActivityType.medical:
        return Icons.medical_services;
      case ActivityType.system:
        return Icons.settings;
    }
  }
}
