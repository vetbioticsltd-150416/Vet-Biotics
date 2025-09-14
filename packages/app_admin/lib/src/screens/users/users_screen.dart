import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_core/core.dart';

import '../../providers/app_admin_provider.dart';
import '../../widgets/user_card.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add user screen
              _showAddUserDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<AppAdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search and Filter Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search users...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (value) {
                          // Implement search functionality
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: 'All',
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Roles')),
                        DropdownMenuItem(value: 'superAdmin', child: Text('Super Admin')),
                        DropdownMenuItem(value: 'clinicAdmin', child: Text('Clinic Admin')),
                        DropdownMenuItem(value: 'veterinarian', child: Text('Veterinarian')),
                        DropdownMenuItem(value: 'receptionist', child: Text('Receptionist')),
                      ],
                      onChanged: (value) {
                        // Implement filter functionality
                      },
                    ),
                  ],
                ),
              ),

              // Users List
              Expanded(
                child: provider.users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: provider.users.length,
                        itemBuilder: (context, index) {
                          final user = provider.users[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: UserCard(
                              user: user,
                              onTap: () {
                                _showUserDetails(context, user);
                              },
                              onEdit: () {
                                _showEditUserDialog(context, user);
                              },
                              onDelete: () {
                                _showDeleteConfirmation(context, user);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          const AlertDialog(title: Text('Add New User'), content: Text('Add user functionality will be implemented')),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${user.role.toString().split('.').last}'),
            if (user.clinicId != null) Text('Clinic ID: ${user.clinicId}'),
            Text('Status: ${user.isActive ? 'Active' : 'Inactive'}'),
            Text('Created: ${user.createdAt.toString().split(' ')[0]}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${user.firstName} ${user.lastName}'),
        content: const Text('Edit user functionality will be implemented'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.firstName} ${user.lastName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppAdminProvider>().removeUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${user.firstName} ${user.lastName} deleted successfully')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
