import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String invoiceId;
  final double remainingAmount;

  const PaymentProcessingScreen({super.key, required this.invoiceId, required this.remainingAmount});

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  PaymentMethod _selectedMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.remainingAmount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xử lý thanh toán'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Thông tin thanh toán', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số tiền cần thanh toán:'),
                          Text(
                            '${widget.remainingAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ',
                            style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Invoice ID: ${widget.invoiceId}', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment method
              Text('Phương thức thanh toán', style: AppTheme.headline2),
              const SizedBox(height: 16),
              _buildPaymentMethodSelector(),

              const SizedBox(height: 24),

              // Payment amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền thanh toán',
                  border: OutlineInputBorder(),
                  suffixText: 'VNĐ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền phải > 0';
                  }
                  if (amount > widget.remainingAmount) {
                    return 'Số tiền không được vượt quá số tiền cần thanh toán';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Reference number (for bank transfers, etc.)
              if (_selectedMethod != PaymentMethod.cash) ...[
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(labelText: _getReferenceLabel(), border: const OutlineInputBorder()),
                  validator: (value) {
                    if (_selectedMethod != PaymentMethod.cash && (value == null || value.isEmpty)) {
                      return 'Vui lòng nhập ${_getReferenceLabel().toLowerCase()}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Process payment button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isProcessing ? const CircularProgressIndicator() : const Text('Xử lý thanh toán'),
                ),
              ),

              const SizedBox(height: 24),

              // Payment method info
              _buildPaymentMethodInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PaymentMethod.values.map((method) {
        final isSelected = _selectedMethod == method;
        return InkWell(
          onTap: () => setState(() => _selectedMethod = method),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getPaymentMethodIcon(method), color: isSelected ? AppTheme.primaryColor : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  method.displayName,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông tin phương thức thanh toán', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(_getPaymentMethodDescription(), style: AppTheme.caption),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final amount = double.parse(_amountController.text);

    // Create payment record
    final payment = Payment(
      invoiceId: widget.invoiceId,
      customerId: 'customer_id', // TODO: Get from invoice
      amount: amount,
      method: _selectedMethod,
      referenceNumber: _referenceController.text.isEmpty ? null : _referenceController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    final databaseProvider = context.read<DatabaseProvider>();
    final paymentId = await databaseProvider.createPayment(payment);

    if (paymentId != null) {
      // Process the payment (mark as completed for demo)
      await databaseProvider.processPayment(paymentId);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanh toán đã được xử lý thành công')));

      Navigator.of(context).pop(true); // Return success
    }

    setState(() => _isProcessing = false);
  }

  String _getReferenceLabel() {
    switch (_selectedMethod) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        return 'Số thẻ';
      case PaymentMethod.bankTransfer:
        return 'Mã giao dịch';
      case PaymentMethod.digitalWallet:
        return 'Mã giao dịch';
      case PaymentMethod.insurance:
        return 'Mã bảo hiểm';
      default:
        return 'Mã tham chiếu';
    }
  }

  String _getPaymentMethodDescription() {
    switch (_selectedMethod) {
      case PaymentMethod.cash:
        return 'Khách hàng thanh toán bằng tiền mặt tại phòng khám.';
      case PaymentMethod.creditCard:
        return 'Thanh toán bằng thẻ tín dụng. Vui lòng nhập số thẻ.';
      case PaymentMethod.debitCard:
        return 'Thanh toán bằng thẻ ghi nợ. Vui lòng nhập số thẻ.';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản ngân hàng. Vui lòng nhập mã giao dịch.';
      case PaymentMethod.digitalWallet:
        return 'Ví điện tử (MoMo, ZaloPay, etc.). Vui lòng nhập mã giao dịch.';
      case PaymentMethod.insurance:
        return 'Thanh toán bằng bảo hiểm. Vui lòng nhập mã bảo hiểm.';
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

