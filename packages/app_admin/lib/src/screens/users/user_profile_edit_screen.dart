import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class UserProfileEditScreen extends StatefulWidget {
  final String userId;

  const UserProfileEditScreen({super.key, required this.userId});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();
    final profile = await databaseProvider.getUserProfile(widget.userId) as UserProfile?;

    if (profile != null) {
      setState(() {
        _userProfile = profile;
        _displayNameController.text = profile.displayName ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
        _addressController.text = profile.address ?? '';
        _bioController.text = profile.bio ?? '';
        _selectedGender = profile.gender;
        _selectedDateOfBirth = profile.dateOfBirth;
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
        appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
        body: const Center(child: Text('Không tìm thấy người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Lưu'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: _getRoleColor(_userProfile!.role).withOpacity(0.1),
                      backgroundImage: _userProfile!.avatarUrl != null ? NetworkImage(_userProfile!.avatarUrl!) : null,
                      child: _userProfile!.avatarUrl == null
                          ? Icon(_getRoleIcon(_userProfile!.role), size: 40, color: _getRoleColor(_userProfile!.role))
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(_userProfile!.email, style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondaryColor)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Basic Information
              Text('Thông tin cơ bản', style: AppTheme.headline2),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _displayNameController,
                label: 'Họ tên hiển thị',
                hint: 'Nhập họ tên hiển thị',
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Vui lòng nhập họ tên hiển thị';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                hint: 'Nhập số điện thoại',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Date of birth
              _buildDatePicker(
                label: 'Ngày sinh',
                selectedDate: _selectedDateOfBirth,
                onDateSelected: (date) => setState(() => _selectedDateOfBirth = date),
              ),
              const SizedBox(height: 16),

              // Gender
              _buildDropdownField(
                label: 'Giới tính',
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 16),

              _buildTextField(controller: _addressController, label: 'Địa chỉ', hint: 'Nhập địa chỉ', maxLines: 2),

              const SizedBox(height: 32),

              // Bio
              Text('Tiểu sử', style: AppTheme.headline2),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Tiểu sử',
                hint: 'Viết một chút về bản thân...',
                maxLines: 4,
              ),

              const SizedBox(height: 32),

              // Account Information (Read-only)
              Text('Thông tin tài khoản', style: AppTheme.headline2),
              const SizedBox(height: 16),
              _buildReadOnlyField('Email', _userProfile!.email),
              const SizedBox(height: 8),
              _buildReadOnlyField('Vai trò', _userProfile!.role.displayName),
              const SizedBox(height: 8),
              _buildReadOnlyField('ID người dùng', _userProfile!.userId),
              const SizedBox(height: 8),
              _buildReadOnlyField('Trạng thái', _userProfile!.isActive ? 'Hoạt động' : 'Không hoạt động'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate != null ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}' : 'Chọn ngày',
              style: TextStyle(color: selectedDate != null ? null : Colors.grey),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
                const SizedBox(height: 4),
                Text(value, style: AppTheme.bodyText2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updates = {
      'displayName': _displayNameController.text.trim(),
      'phoneNumber': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      'gender': _selectedGender,
      'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
    };

    final databaseProvider = context.read<DatabaseProvider>();
    await databaseProvider.updateUserProfile(widget.userId, updates);

    // Log activity
    final activity = UserActivity(
      userId: 'admin', // Current admin user
      type: ActivityType.update,
      action: 'Cập nhật hồ sơ người dùng',
      description: 'Chỉnh sửa thông tin hồ sơ của ${_userProfile!.email}',
      relatedEntityId: widget.userId,
      relatedEntityType: 'user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    await databaseProvider.logUserActivity(activity);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật hồ sơ thành công')));
      Navigator.of(context).pop();
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


