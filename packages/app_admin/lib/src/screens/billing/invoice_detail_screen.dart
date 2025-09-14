import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'payment_processing_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  Invoice? _invoice;
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  Future<void> _loadInvoiceData() async {
    setState(() => _isLoading = true);

    final databaseProvider = context.read<DatabaseProvider>();

    final invoice = await databaseProvider.getInvoice(widget.invoiceId) as Invoice?;
    if (invoice != null) {
      final payments = await databaseProvider.getInvoicePayments(widget.invoiceId) as List<Payment>;
      setState(() {
        _invoice = invoice;
        _payments = payments;
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết hóa đơn')),
        body: const Center(child: Text('Không tìm thấy hóa đơn')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hóa đơn ${_invoice!.invoiceNumber}'),
        elevation: 0,
        actions: [IconButton(onPressed: () => _showInvoiceOptions(context), icon: const Icon(Icons.more_vert))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice header
            _buildInvoiceHeader(),

            const SizedBox(height: 24),

            // Invoice items
            Text('Chi tiết dịch vụ', style: AppTheme.headline2),
            const SizedBox(height: 16),
            _buildInvoiceItems(),

            const SizedBox(height: 24),

            // Invoice summary
            _buildInvoiceSummary(),

            const SizedBox(height: 24),

            // Payments
            if (_payments.isNotEmpty) ...[
              Text('Lịch sử thanh toán', style: AppTheme.headline2),
              const SizedBox(height: 16),
              _buildPaymentsList(),
              const SizedBox(height: 24),
            ],

            // Payment actions
            if (!_invoice!.status.isPaid && !_invoice!.status.isCancelled) _buildPaymentActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_invoice!.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _invoice!.status.displayName,
                    style: TextStyle(color: _getStatusColor(_invoice!.status), fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(_invoice!.invoiceNumber, style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày phát hành', style: AppTheme.caption),
                      Text(
                        '${_invoice!.issueDate.day}/${_invoice!.issueDate.month}/${_invoice!.issueDate.year}',
                        style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (_invoice!.dueDate != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ngày đến hạn', style: AppTheme.caption),
                        Text(
                          '${_invoice!.dueDate!.day}/${_invoice!.dueDate!.month}/${_invoice!.dueDate!.year}',
                          style: AppTheme.bodyText2.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _invoice!.isOverdue ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            if (_invoice!.isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Hóa đơn đã quá hạn', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceItems() {
    return Card(
      child: Column(
        children: _invoice!.items.map((item) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: _invoice!.items.last != item ? Border(bottom: BorderSide(color: AppTheme.borderColor)) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.serviceName, style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600)),
                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(item.description, style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                      style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${item.quantity}x ${item.unitPrice.toInt()} VNĐ',
                      style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng phụ:', style: AppTheme.bodyText2),
                Text(
                  '${_invoice!.subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                  style: AppTheme.bodyText2,
                ),
              ],
            ),
            if (_invoice!.discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Giảm giá:', style: AppTheme.bodyText2),
                  Text(
                    '-${_invoice!.discountAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                    style: AppTheme.bodyText2.copyWith(color: AppTheme.successColor),
                  ),
                ],
              ),
            ],
            if (_invoice!.taxAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Thuế (${_invoice!.taxRate}%):', style: AppTheme.bodyText2),
                  Text(
                    '${_invoice!.taxAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                    style: AppTheme.bodyText2,
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tổng cộng:', style: AppTheme.headline3.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${_invoice!.totalAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                  style: AppTheme.headline3.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    return Card(
      child: Column(
        children: _payments.map((payment) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: _payments.last != payment ? Border(bottom: BorderSide(color: AppTheme.borderColor)) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(payment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPaymentMethodIcon(payment.method),
                    color: _getPaymentStatusColor(payment.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                        style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${payment.method.displayName} - ${payment.status.displayName}',
                        style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
                if (payment.paymentDate != null)
                  Text('${payment.paymentDate!.day}/${payment.paymentDate!.month}', style: AppTheme.caption),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentActions() {
    final totalPaid = _payments.where((p) => p.status.isSuccessful).fold<double>(0, (sum, p) => sum + p.amount);
    final remainingAmount = _invoice!.totalAmount - totalPaid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thanh toán', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Số tiền còn lại: ${remainingAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
              style: AppTheme.bodyText2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPaymentProcessing(context, remainingAmount),
                    icon: const Icon(Icons.payment),
                    label: const Text('Xử lý thanh toán'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa hóa đơn'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to edit invoice screen
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tính năng chỉnh sửa hóa đơn đang phát triển')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Gửi hóa đơn'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Send invoice via email
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tính năng gửi hóa đơn đang phát triển')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('In hóa đơn'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Print invoice
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Tính năng in hóa đơn đang phát triển')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Hủy hóa đơn', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showCancelInvoiceDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPaymentProcessing(BuildContext context, double remainingAmount) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PaymentProcessingScreen(invoiceId: widget.invoiceId, remainingAmount: remainingAmount),
          ),
        )
        .then((result) {
          if (result == true) {
            // Payment was successful, reload data
            _loadInvoiceData();
          }
        });
  }

  void _showCancelInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy hóa đơn'),
        content: const Text('Bạn có chắc muốn hủy hóa đơn này? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelInvoice();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy hóa đơn'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelInvoice() async {
    final databaseProvider = context.read<DatabaseProvider>();
    await databaseProvider.updateInvoice(widget.invoiceId, {'status': 'cancelled'});

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy hóa đơn')));

    _loadInvoiceData();
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

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return AppTheme.successColor;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.credit_card;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentMethod.insurance:
        return Icons.health_and_safety;
    }
  }
}
