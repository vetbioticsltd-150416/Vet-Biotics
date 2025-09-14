import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vet_biotics_shared/shared.dart';
import 'package:vet_biotics_core/core.dart';
import '../../providers/app_clinic_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String? _categoryFilter;
  bool _showLowStockOnly = false;

  final List<String> _categories = [
    'Medications',
    'Vaccines',
    'Equipment',
    'Supplies',
    'Food',
    'Treats',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppClinicProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Inventory',
              style: AppTheme.headline2,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.pushNamed(context, '/add-inventory'),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              _buildLowStockAlert(provider.lowStockItems),
              Expanded(
                child: _buildInventoryList(provider),
              ),
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
          hintText: 'Search inventory...',
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_categoryFilter != null || _showLowStockOnly)
            Expanded(
              child: Wrap(
                spacing: 8,
                children: [
                  if (_categoryFilter != null)
                    Chip(
                      label: Text(_categoryFilter!),
                      onDeleted: () {
                        setState(() {
                          _categoryFilter = null;
                        });
                      },
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.primaryColor,
                    ),
                  if (_showLowStockOnly)
                    Chip(
                      label: const Text('Low Stock Only'),
                      onDeleted: () {
                        setState(() {
                          _showLowStockOnly = false;
                        });
                      },
                      backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                      deleteIconColor: AppTheme.warningColor,
                    ),
                ],
              ),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                _categoryFilter = null;
                _showLowStockOnly = false;
              });
            },
            child: Text(
              'Clear All',
              style: AppTheme.bodyText2.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(List<InventoryItem> lowStockItems) {
    if (lowStockItems.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${lowStockItems.length} item${lowStockItems.length > 1 ? 's' : ''} running low',
                  style: AppTheme.bodyText2.copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Consider restocking these items',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.warningColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _showLowStockOnly = true;
              });
            },
            child: Text(
              'View',
              style: AppTheme.button.copyWith(
                color: AppTheme.warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList(AppClinicProvider provider) {
    // Mock inventory data - in real app this would come from provider
    final mockItems = _getMockInventoryItems();
    final filteredItems = _filterInventoryItems(mockItems);

    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return _buildInventoryCard(filteredItems[index]);
      },
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final isLowStock = item.currentStock <= item.minStockLevel;

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
                Expanded(
                  child: Text(
                    item.name,
                    style: AppTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category,
                    style: AppTheme.caption.copyWith(
                      color: _getCategoryColor(item.category),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (item.description != null) ...[
              Text(
                item.description!,
                style: AppTheme.bodyText2.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Stock',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${item.currentStock}',
                            style: AppTheme.bodyText2.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isLowStock ? AppTheme.errorColor : AppTheme.successColor,
                            ),
                          ),
                          Text(
                            ' / ${item.maxStockLevel}',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unit Price',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Text(
                        '\$${item.unitPrice.toStringAsFixed(2)}',
                        style: AppTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Value',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      Text(
                        '\$${(item.currentStock * item.unitPrice).toStringAsFixed(2)}',
                        style: AppTheme.bodyText2.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLowStock) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppTheme.errorColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Low stock alert',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              LinearProgressIndicator(
                value: item.currentStock / item.maxStockLevel,
                backgroundColor: AppTheme.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  item.currentStock > item.minStockLevel
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStock(item, -1),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.errorColor),
                    ),
                    child: Text(
                      'Reduce',
                      style: AppTheme.button.copyWith(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateStock(item, 1),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.successColor),
                    ),
                    child: Text(
                      'Add',
                      style: AppTheme.button.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editItem(item),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: Text(
                      'Edit',
                      style: AppTheme.button.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory,
            size: 80,
            color: AppTheme.textHintColor,
          ),
          const SizedBox(height: 24),
          Text(
            'No inventory items found',
            style: AppTheme.headline2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to track your inventory',
            style: AppTheme.bodyText2.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/add-inventory'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
              child: Text(
                'Add Item',
                style: AppTheme.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InventoryItem> _filterInventoryItems(List<InventoryItem> items) {
    return items.where((item) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery) ||
          (item.description?.toLowerCase().contains(_searchQuery) ?? false);

      // Category filter
      final matchesCategory = _categoryFilter == null ||
          item.category.toLowerCase() == _categoryFilter!.toLowerCase();

      // Low stock filter
      final matchesLowStock = !_showLowStockOnly || item.currentStock <= item.minStockLevel;

      return matchesSearch && matchesCategory && matchesLowStock;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Filter Inventory',
            style: AppTheme.headline2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: AppTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _categoryFilter == category,
                    onSelected: (selected) {
                      setState(() {
                        _categoryFilter = selected ? category : null;
                      });
                      this.setState(() {});
                    },
                    backgroundColor: AppTheme.surfaceColor,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                    checkmarkColor: AppTheme.primaryColor,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Low Stock Only',
                    style: AppTheme.bodyText1.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _showLowStockOnly,
                    onChanged: (value) {
                      setState(() {
                        _showLowStockOnly = value;
                      });
                      this.setState(() {});
                    },
                    activeThumbColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _categoryFilter = null;
                  _showLowStockOnly = false;
                });
                this.setState(() {});
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear All',
                style: AppTheme.button.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: Text(
                'Apply',
                style: AppTheme.button.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStock(InventoryItem item, int change) {
    // TODO: Implement stock update functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stock update functionality coming soon',
          style: TextStyle(color: AppTheme.surfaceColor),
        ),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _editItem(InventoryItem item) {
    // TODO: Navigate to edit inventory item screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit functionality coming soon',
          style: TextStyle(color: AppTheme.surfaceColor),
        ),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'medications':
        return AppTheme.primaryColor;
      case 'vaccines':
        return AppTheme.secondaryColor;
      case 'equipment':
        return AppTheme.accentColor;
      case 'supplies':
        return AppTheme.infoColor;
      case 'food':
        return Colors.orange;
      case 'treats':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  List<InventoryItem> _getMockInventoryItems() {
    return [
      InventoryItem(
        id: '1',
        name: 'Amoxicillin 500mg',
        description: 'Antibiotic medication',
        category: 'Medications',
        currentStock: 25,
        minStockLevel: 10,
        maxStockLevel: 100,
        unitPrice: 0.50,
        supplier: 'MediCorp',
        expiryDate: DateTime(2025, 12, 31),
      ),
      InventoryItem(
        id: '2',
        name: 'Distemper Vaccine',
        description: 'Canine distemper vaccine',
        category: 'Vaccines',
        currentStock: 5,
        minStockLevel: 20,
        maxStockLevel: 50,
        unitPrice: 15.00,
        supplier: 'VetVax Inc',
        expiryDate: DateTime(2024, 6, 30),
      ),
      InventoryItem(
        id: '3',
        name: 'Surgical Gloves',
        description: 'Size M latex-free gloves',
        category: 'Supplies',
        currentStock: 45,
        minStockLevel: 20,
        maxStockLevel: 200,
        unitPrice: 0.25,
        supplier: 'MediSupplies',
        expiryDate: null,
      ),
      InventoryItem(
        id: '4',
        name: 'Dog Food Premium',
        description: 'Adult dog food 20kg bags',
        category: 'Food',
        currentStock: 8,
        minStockLevel: 5,
        maxStockLevel: 50,
        unitPrice: 45.00,
        supplier: 'PetFoods Ltd',
        expiryDate: DateTime(2024, 12, 31),
      ),
    ];
  }
}
