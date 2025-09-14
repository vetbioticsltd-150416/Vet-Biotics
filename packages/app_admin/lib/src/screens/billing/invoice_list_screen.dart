import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

import 'create_invoice_screen.dart';
import 'invoice_detail_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String? _selectedClinicId;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    // For admin, we might want to show all invoices or filter by clinic
    // For now, we'll show all clinics first to select one
    final clinics = await databaseProvider.getAllClinics() as List<Clinic>;

    if (clinics.isNotEmpty) {
      _selectedClinicId = clinics.first.id;
      final invoices = await databaseProvider.getClinicInvoices(_selectedClinicId!) as List<Invoice>;
      setState(() {
        _invoices = invoices;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý hóa đơn'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showCreateInvoiceDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Tạo hóa đơn',
          ),
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildInvoicesView(),
    );
  }

  Widget _buildInvoicesView() {
    return Column(
      children: [
        // Clinic selector
        _buildClinicSelector(),

        // Invoices list
        Expanded(child: _invoices.isEmpty ? _buildEmptyState() : _buildInvoicesList()),
      ],
    );
  }

  Widget _buildClinicSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          const Text('Phòng khám:', style: AppTheme.bodyText2),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: const Text('Tất cả phòng khám'), // TODO: Implement clinic dropdown
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Chưa có hóa đơn nào', style: AppTheme.headline3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Tạo hóa đơn đầu tiên cho phòng khám',
            style: AppTheme.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateInvoiceDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Tạo hóa đơn'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    return RefreshIndicator(
      onRefresh: _loadInvoices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _invoices.length,
        itemBuilder: (context, index) {
          final invoice = _invoices[index];
          return _buildInvoiceCard(invoice);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => InvoiceDetailScreen(invoiceId: invoice.id!))),
        borderRadius: BorderRadius.circular(12),
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
                      color: _getStatusColor(invoice.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invoice.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(invoice.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(invoice.invoiceNumber, style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${invoice.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                          style: AppTheme.headline3.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ngày: ${invoice.issueDate.day}/${invoice.issueDate.month}/${invoice.issueDate.year}',
                          style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                  if (invoice.dueDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: invoice.isOverdue ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        invoice.isOverdue ? 'Quá hạn' : 'Còn ${invoice.daysUntilDue} ngày',
                        style: TextStyle(
                          color: invoice.isOverdue ? Colors.red : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),
              Text(
                '${invoice.items.length} dịch vụ',
                style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()))
        .then((_) => _loadInvoices()); // Reload after creating invoice
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return AppTheme.successColor;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.red;
    }
  }
}
