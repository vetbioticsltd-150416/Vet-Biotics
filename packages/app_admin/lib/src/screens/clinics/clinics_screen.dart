import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_core/core.dart';

import '../../providers/app_admin_provider.dart';
import '../../widgets/clinic_card.dart';

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add clinic screen
              _showAddClinicDialog(context);
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
                          hintText: 'Search clinics...',
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
                        DropdownMenuItem(value: 'All', child: Text('All Status')),
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (value) {
                        // Implement filter functionality
                      },
                    ),
                  ],
                ),
              ),

              // Clinics List
              Expanded(
                child: provider.clinics.isEmpty
                    ? const Center(child: Text('No clinics found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: provider.clinics.length,
                        itemBuilder: (context, index) {
                          final clinic = provider.clinics[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ClinicCard(
                              clinic: clinic,
                              onTap: () {
                                _showClinicDetails(context, clinic);
                              },
                              onEdit: () {
                                _showEditClinicDialog(context, clinic);
                              },
                              onDelete: () {
                                _showDeleteConfirmation(context, clinic);
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

  void _showAddClinicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Add New Clinic'),
        content: Text('Add clinic functionality will be implemented'),
      ),
    );
  }

  void _showClinicDetails(BuildContext context, Clinic clinic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clinic.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${clinic.address}'),
            Text('Phone: ${clinic.phone}'),
            Text('Email: ${clinic.email}'),
            Text('Status: ${clinic.isActive ? 'Active' : 'Inactive'}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showEditClinicDialog(BuildContext context, Clinic clinic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${clinic.name}'),
        content: const Text('Edit clinic functionality will be implemented'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Clinic clinic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Clinic'),
        content: Text('Are you sure you want to delete ${clinic.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppAdminProvider>().removeClinic(clinic.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${clinic.name} deleted successfully')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
