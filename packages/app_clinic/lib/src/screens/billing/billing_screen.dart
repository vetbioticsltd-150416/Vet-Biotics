import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Billing', style: AppTheme.headline2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.add), onPressed: () => Navigator.pushNamed(context, '/new-bill')),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Today'),
                Tab(text: 'Pending'),
                Tab(text: 'History'),
              ],
              labelStyle: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
              unselectedLabelStyle: AppTheme.bodyText2,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondaryColor,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTodayBilling(provider.todayBilling.where((b) => b.status == BillingStatus.paid).toList()),
              _buildPendingBilling(provider.todayBilling.where((b) => b.status != BillingStatus.paid).toList()),
              _buildBillingHistory([]), // TODO: Implement billing history
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayBilling(List<Billing> billing) {
    return Column(
      children: [
        _buildRevenueSummary(billing),
        Expanded(
          child: billing.isEmpty
              ? _buildEmptyState('No payments received today')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: billing.length,
                  itemBuilder: (context, index) {
                    return _buildBillingCard(billing[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPendingBilling(List<Billing> billing) {
    return billing.isEmpty
        ? _buildEmptyState('No pending payments')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: billing.length,
            itemBuilder: (context, index) {
              return _buildBillingCard(billing[index], showActions: true);
            },
          );
  }

  Widget _buildBillingHistory(List<Billing> billing) {
    return billing.isEmpty
        ? _buildEmptyState('No billing history available')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: billing.length,
            itemBuilder: (context, index) {
              return _buildBillingCard(billing[index]);
            },
          );
  }

  Widget _buildRevenueSummary(List<Billing> billing) {
    final totalRevenue = billing.fold<double>(0, (sum, bill) => sum + bill.totalAmount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        children: [
          Text('Today\'s Revenue', style: AppTheme.bodyText2.copyWith(color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 8),
          Text(
            '\$${totalRevenue.toStringAsFixed(2)}',
            style: AppTheme.headline1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${billing.length} payment${billing.length != 1 ? 's' : ''} received',
            style: AppTheme.caption.copyWith(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingCard(Billing billing, {bool showActions = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill #${billing.id.substring(0, 8)}',
                  style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600),
                ),
                _buildStatusChip(billing.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.pets, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(billing.petName, style: AppTheme.bodyText2)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(billing.ownerName, style: AppTheme.bodyText2)),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: AppTheme.borderColor),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
                    Text(
                      '${billing.date.day}/${billing.date.month}/${billing.date.year}',
                      style: AppTheme.bodyText2.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total Amount', style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
                    Text(
                      '\$${billing.totalAmount.toStringAsFixed(2)}',
                      style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
            if (billing.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Items:', style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor)),
              const SizedBox(height: 4),
              ...billing.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.description, style: AppTheme.caption),
                      Text(
                        '\$${item.amount.toStringAsFixed(2)}',
                        style: AppTheme.caption.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (showActions && billing.status != BillingStatus.paid) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _markAsPaid(billing),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.successColor)),
                      child: Text('Mark as Paid', style: AppTheme.button.copyWith(color: AppTheme.successColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _printBill(billing),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryColor)),
                      child: Text('Print', style: AppTheme.button.copyWith(color: AppTheme.primaryColor)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BillingStatus status) {
    Color color;
    String text;

    switch (status) {
      case BillingStatus.pending:
        color = AppTheme.warningColor;
        text = 'Pending';
        break;
      case BillingStatus.paid:
        color = AppTheme.successColor;
        text = 'Paid';
        break;
      case BillingStatus.overdue:
        color = AppTheme.errorColor;
        text = 'Overdue';
        break;
      case BillingStatus.cancelled:
        color = AppTheme.textSecondaryColor;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTheme.caption.copyWith(color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: AppTheme.textHintColor),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTheme.headline2.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (message.contains('No pending payments'))
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/new-bill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
                ),
                child: Text('Create Bill', style: AppTheme.button.copyWith(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  void _markAsPaid(Billing billing) {
    final provider = context.read<AppClinicProvider>();
    // TODO: Update billing status in backend
    // For now, just update locally
    final updatedBilling = billing.copyWith(status: BillingStatus.paid);
    // provider.updateBilling(updatedBilling);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment marked as received', style: TextStyle(color: AppTheme.surfaceColor)),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _printBill(Billing billing) {
    // TODO: Implement bill printing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing functionality coming soon', style: TextStyle(color: AppTheme.surfaceColor)),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
