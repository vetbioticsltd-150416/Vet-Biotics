import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 1,
  );

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompactCurrency(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  static String formatCurrencyWithoutSymbol(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  static String formatPriceRange(double minPrice, double maxPrice) {
    if (minPrice == maxPrice) {
      return formatCurrency(minPrice);
    }
    return '${formatCurrency(minPrice)} - ${formatCurrency(maxPrice)}';
  }

  static String formatDiscount(double originalPrice, double discountedPrice) {
    final discount = originalPrice - discountedPrice;
    final discountPercentage = ((discount / originalPrice) * 100).round();

    return '${formatCurrency(discount)} ($discountPercentage%)';
  }

  static String formatWithTax(double amount, double taxRate) {
    final taxAmount = amount * (taxRate / 100);
    final totalAmount = amount + taxAmount;

    return formatCurrency(totalAmount);
  }

  static String formatTaxBreakdown(double amount, double taxRate) {
    final taxAmount = amount * (taxRate / 100);
    final totalAmount = amount + taxAmount;

    return '${formatCurrency(amount)} + ${formatCurrency(taxAmount)} tax = ${formatCurrency(totalAmount)}';
  }

  static String formatChange(double amount) {
    if (amount >= 0) {
      return '+${formatCurrency(amount)}';
    } else {
      return formatCurrency(amount);
    }
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatAmountWithSign(double amount, {String positivePrefix = '+', String negativePrefix = ''}) {
    if (amount >= 0) {
      return '$positivePrefix${formatCurrency(amount)}';
    } else {
      return '$negativePrefix${formatCurrency(amount)}';
    }
  }
}
