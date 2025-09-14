import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedClinicId;
  String? _selectedCustomerId;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;
  final List<InvoiceItem> _items = [];
  double _taxRate = 0.0;
  double _discountAmount = 0.0;

  bool _isLoading = false;
  List<Clinic> _clinics = [];

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    final databaseProvider = context.read<DatabaseProvider>();
    final clinics = await databaseProvider.getAllClinics() as List<Clinic>;
    setState(() {
      _clinics = clinics;
      if (_clinics.isNotEmpty) {
        _selectedClinicId = _clinics.first.id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo hóa đơn mới'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInvoice,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Tạo'),
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
              // Clinic selection
              DropdownButtonFormField<String>(
                initialValue: _selectedClinicId,
                decoration: const InputDecoration(labelText: 'Phòng khám *', border: OutlineInputBorder()),
                items: _clinics.map((clinic) {
                  return DropdownMenuItem(value: clinic.id, child: Text(clinic.name));
                }).toList(),
                validator: (value) => value == null ? 'Vui lòng chọn phòng khám' : null,
                onChanged: (value) => setState(() => _selectedClinicId = value),
              ),
              const SizedBox(height: 16),

              // Customer selection (simplified)
              TextFormField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Khách hàng *',
                  border: OutlineInputBorder(),
                  hintText: 'Nhập ID khách hàng',
                ),
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập ID khách hàng' : null,
                onChanged: (value) => _selectedCustomerId = value,
              ),
              const SizedBox(height: 16),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Ngày phát hành'),
                      subtitle: Text('${_issueDate.day}/${_issueDate.month}/${_issueDate.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListTile(
                      title: const Text('Ngày đến hạn'),
                      subtitle: _dueDate != null
                          ? Text('${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}')
                          : const Text('Không có'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Invoice items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dịch vụ', style: AppTheme.headline2),
                  TextButton.icon(onPressed: _addInvoiceItem, icon: const Icon(Icons.add), label: const Text('Thêm')),
                ],
              ),
              const SizedBox(height: 8),

              if (_items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Chưa có dịch vụ nào'),
                )
              else
                ..._items.map((item) => _buildInvoiceItemTile(item)),

              const SizedBox(height: 24),

              // Tax and discount
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _taxRate.toString(),
                      decoration: const InputDecoration(labelText: 'Thuế (%)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() => _taxRate = double.tryParse(value) ?? 0.0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _discountAmount.toString(),
                      decoration: const InputDecoration(labelText: 'Giảm giá (VNĐ)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() => _discountAmount = double.tryParse(value) ?? 0.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder()),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Summary
              _buildInvoiceSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceItemTile(InvoiceItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.serviceName),
        subtitle: Text('${item.quantity}x ${item.unitPrice.toInt()} VNĐ = ${item.totalPrice.toInt()} VNĐ'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeInvoiceItem(item),
        ),
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    final totals = Invoice.calculateTotals(_items, _taxRate, _discountAmount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tóm tắt', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng phụ:'),
                Text(
                  '${totals['subtotal']!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                ),
              ],
            ),
            if (_discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giảm giá:'),
                  Text(
                    '-${_discountAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                  ),
                ],
              ),
            ],
            if (totals['taxAmount']! > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Thuế ($_taxRate%):'),
                  Text(
                    '${totals['taxAmount']!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                  ),
                ],
              ),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng cộng:', style: AppTheme.headline3.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${totals['totalAmount']!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                  style: AppTheme.headline3.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : (_dueDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = pickedDate;
        } else {
          _dueDate = pickedDate;
        }
      });
    }
  }

  void _addInvoiceItem() {
    final serviceNameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final unitPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm dịch vụ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: serviceNameController,
              decoration: const InputDecoration(labelText: 'Tên dịch vụ *'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Số lượng *'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: unitPriceController,
                    decoration: const InputDecoration(labelText: 'Đơn giá *'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final serviceName = serviceNameController.text.trim();
              final quantity = int.tryParse(quantityController.text) ?? 1;
              final unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;

              if (serviceName.isEmpty || unitPrice <= 0) return;

              final item = InvoiceItem(
                serviceId: DateTime.now().millisecondsSinceEpoch.toString(),
                serviceName: serviceName,
                description: '',
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: quantity * unitPrice,
              );

              setState(() => _items.add(item));
              Navigator.of(context).pop();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _removeInvoiceItem(InvoiceItem item) {
    setState(() => _items.remove(item));
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinicId == null || _selectedCustomerId == null) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm ít nhất một dịch vụ')));
      return;
    }

    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    // Generate invoice number
    final invoiceNumber = await databaseProvider.generateInvoiceNumber(_selectedClinicId!);

    // Calculate totals
    final totals = Invoice.calculateTotals(_items, _taxRate, _discountAmount);

    final invoice = Invoice(
      invoiceNumber: invoiceNumber,
      clinicId: _selectedClinicId!,
      customerId: _selectedCustomerId!,
      status: InvoiceStatus.draft,
      issueDate: _issueDate,
      dueDate: _dueDate,
      items: _items,
      subtotal: totals['subtotal']!,
      taxRate: _taxRate,
      taxAmount: totals['taxAmount']!,
      discountAmount: _discountAmount,
      totalAmount: totals['totalAmount']!,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    final invoiceId = await databaseProvider.createInvoice(invoice);

    setState(() => _isLoading = false);

    if (invoiceId != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã tạo hóa đơn thành công')));
      Navigator.of(context).pop();
    }
  }
}

