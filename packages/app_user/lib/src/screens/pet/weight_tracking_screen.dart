import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_auth/auth.dart';
import 'package:vet_biotics_core/core.dart';
import 'package:vet_biotics_shared/shared.dart';

class WeightTrackingScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const WeightTrackingScreen({super.key, required this.petId, required this.petName});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  List<Map<String, dynamic>> _weightRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  Future<void> _loadWeightData() async {
    setState(() => _isLoading = true);

    // Mock weight data - in real app this would come from database
    // This simulates weight tracking over time
    final now = DateTime.now();
    _weightRecords = [
      {'date': now.subtract(const Duration(days: 0)), 'weight': 12.5},
      {'date': now.subtract(const Duration(days: 7)), 'weight': 12.3},
      {'date': now.subtract(const Duration(days: 14)), 'weight': 12.1},
      {'date': now.subtract(const Duration(days: 21)), 'weight': 11.9},
      {'date': now.subtract(const Duration(days: 30)), 'weight': 12.0},
      {'date': now.subtract(const Duration(days: 60)), 'weight': 11.8},
      {'date': now.subtract(const Duration(days: 90)), 'weight': 11.5},
    ];

    setState(() => _isLoading = false);
  }

  Future<void> _addWeightRecord() async {
    final weightController = TextEditingController();
    final selectedDate = DateTime.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm cân nặng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Cân nặng (kg)', suffixText: 'kg'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập cân nặng';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 200) {
                  return 'Cân nặng phải từ 0.1 đến 200 kg';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0 && weight <= 200) {
                Navigator.of(context).pop({'weight': weight, 'date': selectedDate});
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _weightRecords.insert(0, result);
        _weightRecords.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      });

      // TODO: Save to database
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm bản ghi cân nặng')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Theo dõi cân nặng - ${widget.petName}'),
        elevation: 0,
        actions: [IconButton(onPressed: _addWeightRecord, icon: const Icon(Icons.add), tooltip: 'Thêm cân nặng')],
      ),
      body: _weightRecords.isEmpty ? _buildEmptyState() : _buildWeightTrackingView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_weight, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Chưa có dữ liệu cân nặng', style: AppTheme.headline3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Bắt đầu theo dõi cân nặng của thú cưng',
            style: AppTheme.bodyText2.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addWeightRecord,
            icon: const Icon(Icons.add),
            label: const Text('Thêm cân nặng đầu tiên'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrackingView() {
    final currentWeight = _weightRecords.isNotEmpty ? _weightRecords.first['weight'] as double : 0.0;
    final previousWeight = _weightRecords.length > 1 ? _weightRecords[1]['weight'] as double : currentWeight;
    final weightChange = currentWeight - previousWeight;

    return RefreshIndicator(
      onRefresh: _loadWeightData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weight Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cân nặng hiện tại', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${currentWeight.toStringAsFixed(1)} kg',
                          style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: weightChange >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                weightChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 16,
                                color: weightChange >= 0 ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${weightChange.abs().toStringAsFixed(1)} kg',
                                style: AppTheme.caption.copyWith(
                                  color: weightChange >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weightChange >= 0 ? 'Tăng cân' : 'Giảm cân',
                      style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Weight Chart Placeholder (in real app would use charts library)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Biểu đồ cân nặng', style: AppTheme.bodyText1.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('Biểu đồ sẽ hiển thị ở đây')),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theo dõi sự thay đổi cân nặng theo thời gian',
                      style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Weight History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lịch sử cân nặng', style: AppTheme.headline2),
                TextButton(
                  onPressed: () {},
                  child: Text('Xem tất cả', style: AppTheme.bodyText2.copyWith(color: AppTheme.primaryColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ..._weightRecords.take(10).map((record) {
              final date = record['date'] as DateTime;
              final weight = record['weight'] as double;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.monitor_weight, color: AppTheme.primaryColor),
                  ),
                  title: Text('${weight.toStringAsFixed(1)} kg'),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: Text(
                    date == DateTime.now() ? 'Hôm nay' : '${DateTime.now().difference(date).inDays} ngày trước',
                    style: AppTheme.caption.copyWith(color: AppTheme.textSecondaryColor),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

