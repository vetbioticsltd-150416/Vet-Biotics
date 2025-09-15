import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserProfile> _users = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final databaseProvider = context.read<DatabaseProvider>();
      final users = await databaseProvider.getAllUsers() as List<UserProfile>;

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách người dùng: ${e.toString()}')));
      }
    }
  }

  List<UserProfile> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == null || user.role == _selectedRole;
      return matchesSearch && matchesRole && user.isActive;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: const Text('Quản lý người dùng'),
      body: ResponsiveContainer(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc email...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

            // User list
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: EnhancedLoadingIndicator(message: 'Đang tải danh sách người dùng...'));
    }

    if (_hasError) {
      return EnhancedErrorView(
        title: 'Không thể tải danh sách người dùng',
        message: 'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.',
        onRetry: _loadUsers,
      );
    }

    if (_filteredUsers.isEmpty) {
      return EnhancedEmptyView(
        title: 'Không tìm thấy người dùng',
        message: _searchQuery.isEmpty
            ? 'Chưa có người dùng nào trong hệ thống.'
            : 'Không có người dùng nào khớp với tìm kiếm của bạn.',
        icon: Icons.people_outline,
        actionText: _searchQuery.isNotEmpty ? 'Xóa bộ lọc' : null,
        onAction: _searchQuery.isNotEmpty ? () => setState(() => _searchQuery = '') : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return AnimatedListItem(index: index, child: _buildUserCard(user));
        },
      ),
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserDetailScreen(userId: user.userId))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null ? Icon(_getRoleIcon(user.role), color: _getRoleColor(user.role)) : null,
            ),
            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(user.email, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.displayName,
                          style: TextStyle(color: _getRoleColor(user.role), fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (user.clinicId != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.business, size: 12, color: Colors.grey),
                      ],
                      if (user.lastLoginAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Online ${_getLastLoginText(user.lastLoginAt!)}',
                          style: AppTheme.caption.copyWith(color: Colors.green, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: user.isActive ? Colors.green : Colors.red, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lọc theo vai trò', style: AppTheme.headline2),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tất cả'),
                    selected: _selectedRole == null,
                    onSelected: (selected) {
                      setState(() => _selectedRole = null);
                      this.setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),
                  ...UserRole.values.map(
                    (role) => FilterChip(
                      label: Text(role.displayName),
                      selected: _selectedRole == role,
                      onSelected: (selected) {
                        setState(() => _selectedRole = selected ? role : null);
                        this.setState(() {});
                        if (!selected) Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _selectedRole = null);
                        this.setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Xóa bộ lọc'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLastLoginText(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'vừa xong';
    }
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
}
