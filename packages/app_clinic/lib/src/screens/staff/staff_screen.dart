import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String _searchQuery = '';
  String? _roleFilter;

  final List<String> _roles = ['Veterinarian', 'Vet Assistant', 'Receptionist', 'Groomer', 'Manager', 'Admin'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Staff Management', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.add), onPressed: () => Navigator.pushNamed(context, '/add-staff')),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildRoleFilter(),
              Expanded(child: _buildStaffList(provider.staff)),
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
          hintText: 'Search staff...',
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

  Widget _buildRoleFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_roleFilter != null)
            Expanded(
              child: Chip(
                label: Text(_roleFilter!),
                onDeleted: () {
                  setState(() {
                    _roleFilter = null;
                  });
                },
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                deleteIconColor: AppTheme.primaryColor,
              ),
            )
          else
            Expanded(
              child: Text('All Roles', style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
            ),
          PopupMenuButton<String>(
            onSelected: (role) {
              setState(() {
                _roleFilter = role;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Roles')),
              ..._roles.map((role) => PopupMenuItem(value: role, child: Text(role))),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Row(
                children: [
                  Text('Filter by Role', style: AppTheme.bodyText2),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: AppTheme.textSecondaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList(List<User> staff) {
    final filteredStaff = _filterStaff(staff);

    if (filteredStaff.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStaff.length,
      itemBuilder: (context, index) {
        return _buildStaffCard(filteredStaff[index]);
      },
    );
  }

  Widget _buildStaffCard(User staffMember) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(staffMember),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staffMember.name, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(staffMember.role ?? 'Staff').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          staffMember.role ?? 'Staff',
                          style: AppTheme.caption.copyWith(
                            color: _getRoleColor(staffMember.role ?? 'Staff'),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleStaffAction(action, staffMember),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                    const PopupMenuItem(value: 'schedule', child: Text('View Schedule')),
                    const PopupMenuItem(value: 'permissions', child: Text('Manage Permissions')),
                    const PopupMenuItem(value: 'remove', child: Text('Remove Staff')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildContactInfo(Icons.email, staffMember.email ?? 'No email')),
                Expanded(child: _buildContactInfo(Icons.phone, staffMember.phone ?? 'No phone')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Working Hours: 9:00 AM - 6:00 PM',
                  style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Joined: ${_formatJoinDate(staffMember.createdAt ?? DateTime.now())}',
                  style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User staffMember) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getRoleColor(staffMember.role ?? 'Staff').withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRoleColor(staffMember.role ?? 'Staff').withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          _getInitials(staffMember.name),
          style: AppTheme.bodyText1.copyWith(
            color: _getRoleColor(staffMember.role ?? 'Staff'),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String info) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            info,
            style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: AppTheme.textHintColor),
          const SizedBox(height: 24),
          Text('No staff members found', style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor)),
          const SizedBox(height: 8),
          Text(
            'Add staff members to manage your clinic team',
            style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-staff'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
              ),
              child: Text('Add Staff', style: AppTheme.button.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<User> _filterStaff(List<User> staff) {
    return staff.where((member) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          member.name.toLowerCase().contains(_searchQuery) ||
          (member.email?.toLowerCase().contains(_searchQuery) ?? false) ||
          (member.role?.toLowerCase().contains(_searchQuery) ?? false);

      // Role filter
      final matchesRole = _roleFilter == null || member.role?.toLowerCase() == _roleFilter!.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();
  }

  void _handleStaffAction(String action, User staffMember) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit staff screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit functionality coming soon', style: TextStyle(color: AppTheme.surfaceColor)),
            backgroundColor: AppTheme.infoColor,
          ),
        );
        break;
      case 'schedule':
        // TODO: Navigate to staff schedule screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule view coming soon', style: TextStyle(color: AppTheme.surfaceColor)),
            backgroundColor: AppTheme.infoColor,
          ),
        );
        break;
      case 'permissions':
        // TODO: Navigate to permissions management screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permissions management coming soon', style: TextStyle(color: AppTheme.surfaceColor)),
            backgroundColor: AppTheme.infoColor,
          ),
        );
        break;
      case 'remove':
        _showRemoveStaffDialog(staffMember);
        break;
    }
  }

  void _showRemoveStaffDialog(User staffMember) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Staff Member', style: AppTheme.headline2),
        content: Text(
          'Are you sure you want to remove ${staffMember.name} from the staff? This action cannot be undone.',
          style: AppTheme.bodyText2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppTheme.button.copyWith(color: AppTheme.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = context.read<AppClinicProvider>();
              provider.removeStaff(staffMember.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${staffMember.name} has been removed from staff',
                    style: TextStyle(color: AppTheme.surfaceColor),
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: Text('Remove', style: AppTheme.button.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatJoinDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'veterinarian':
        return AppTheme.primaryColor;
      case 'vet assistant':
        return AppTheme.secondaryColor;
      case 'receptionist':
        return AppTheme.accentColor;
      case 'groomer':
        return AppTheme.infoColor;
      case 'manager':
        return Colors.orange;
      case 'admin':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }
}
