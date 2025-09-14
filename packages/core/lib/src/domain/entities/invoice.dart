import 'package:core/src/domain/entities/base_entity.dart';

/// Invoice status
enum InvoiceStatus {
  draft('draft', 'Nháp'),
  sent('sent', 'Đã gửi'),
  paid('paid', 'Đã thanh toán'),
  overdue('overdue', 'Quá hạn'),
  cancelled('cancelled', 'Đã hủy');

  const InvoiceStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static InvoiceStatus fromString(String value) {
    return InvoiceStatus.values.firstWhere((status) => status.value == value, orElse: () => InvoiceStatus.draft);
  }

  bool get isDraft => this == InvoiceStatus.draft;
  bool get isSent => this == InvoiceStatus.sent;
  bool get isPaid => this == InvoiceStatus.paid;
  bool get isOverdue => this == InvoiceStatus.overdue;
  bool get isCancelled => this == InvoiceStatus.cancelled;
}

/// Payment method
enum PaymentMethod {
  cash('cash', 'Tiền mặt'),
  creditCard('credit_card', 'Thẻ tín dụng'),
  debitCard('debit_card', 'Thẻ ghi nợ'),
  bankTransfer('bank_transfer', 'Chuyển khoản'),
  digitalWallet('digital_wallet', 'Ví điện tử'),
  insurance('insurance', 'Bảo hiểm');

  const PaymentMethod(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere((method) => method.value == value, orElse: () => PaymentMethod.cash);
  }
}

/// Invoice entity
class Invoice extends AuditableEntity {
  final String invoiceNumber;
  final String clinicId;
  final String customerId; // User ID
  final String? petId;
  final String? appointmentId;
  final InvoiceStatus status;
  final DateTime issueDate;
  final DateTime? dueDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxRate; // Percentage
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const Invoice({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isActive,
    required this.invoiceNumber,
    required this.clinicId,
    required this.customerId,
    this.petId,
    this.appointmentId,
    this.status = InvoiceStatus.draft,
    required this.issueDate,
    this.dueDate,
    required this.items,
    required this.subtotal,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.discountAmount = 0.0,
    required this.totalAmount,
    this.notes,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    invoiceNumber,
    clinicId,
    customerId,
    petId,
    appointmentId,
    status,
    issueDate,
    dueDate,
    items,
    subtotal,
    taxRate,
    taxAmount,
    discountAmount,
    totalAmount,
    notes,
    metadata,
  ];

  @override
  bool get isValid {
    return super.isValid &&
        invoiceNumber.isNotEmpty &&
        clinicId.isNotEmpty &&
        customerId.isNotEmpty &&
        items.isNotEmpty &&
        subtotal >= 0 &&
        totalAmount >= 0;
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (invoiceNumber.isEmpty) {
      errors.add('Số hóa đơn không được để trống');
    }

    if (clinicId.isEmpty) {
      errors.add('Phòng khám không được để trống');
    }

    if (customerId.isEmpty) {
      errors.add('Khách hàng không được để trống');
    }

    if (items.isEmpty) {
      errors.add('Hóa đơn phải có ít nhất một mục');
    }

    if (subtotal < 0) {
      errors.add('Tổng phụ phải >= 0');
    }

    if (totalAmount < 0) {
      errors.add('Tổng tiền phải >= 0');
    }

    if (taxRate < 0 || taxRate > 100) {
      errors.add('Thuế suất phải từ 0 đến 100');
    }

    return errors;
  }

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? clinicId,
    String? customerId,
    String? petId,
    String? appointmentId,
    InvoiceStatus? status,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      clinicId: clinicId ?? this.clinicId,
      customerId: customerId ?? this.customerId,
      petId: petId ?? this.petId,
      appointmentId: appointmentId ?? this.appointmentId,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Calculate totals from items
  static Map<String, double> calculateTotals(List<InvoiceItem> items, double taxRate, double discountAmount) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

    final taxableAmount = subtotal - discountAmount;
    final taxAmount = taxableAmount * (taxRate / 100);
    final totalAmount = taxableAmount + taxAmount;

    return {'subtotal': subtotal, 'taxAmount': taxAmount, 'totalAmount': totalAmount};
  }

  /// Check if invoice is overdue
  bool get isOverdue {
    if (dueDate == null || status.isPaid || status.isCancelled) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Get days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }
}

/// Invoice item
class InvoiceItem {
  final String serviceId;
  final String serviceName;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic>? metadata;

  const InvoiceItem({
    required this.serviceId,
    required this.serviceName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.metadata,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'metadata': metadata,
    };
  }

  InvoiceItem copyWith({
    String? serviceId,
    String? serviceName,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    Map<String, dynamic>? metadata,
  }) {
    return InvoiceItem(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Payment entity
class Payment extends AuditableEntity {
  final String invoiceId;
  final String customerId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime? paymentDate;
  final String? transactionId;
  final String? referenceNumber;
  final String? notes;
  final Map<String, dynamic>? paymentDetails;
  final Map<String, dynamic>? metadata;

  const Payment({
    super.id,
    super.createdAt,
    super.updatedAt,
    super.isActive,
    required this.invoiceId,
    required this.customerId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    this.paymentDate,
    this.transactionId,
    this.referenceNumber,
    this.notes,
    this.paymentDetails,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    invoiceId,
    customerId,
    amount,
    method,
    status,
    paymentDate,
    transactionId,
    referenceNumber,
    notes,
    paymentDetails,
    metadata,
  ];

  @override
  bool get isValid {
    return super.isValid && invoiceId.isNotEmpty && customerId.isNotEmpty && amount > 0;
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (invoiceId.isEmpty) {
      errors.add('Hóa đơn không được để trống');
    }

    if (customerId.isEmpty) {
      errors.add('Khách hàng không được để trống');
    }

    if (amount <= 0) {
      errors.add('Số tiền phải > 0');
    }

    return errors;
  }

  Payment copyWith({
    String? id,
    String? invoiceId,
    String? customerId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? transactionId,
    String? referenceNumber,
    String? notes,
    Map<String, dynamic>? paymentDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Payment status
enum PaymentStatus {
  pending('pending', 'Chờ xử lý'),
  processing('processing', 'Đang xử lý'),
  completed('completed', 'Hoàn thành'),
  failed('failed', 'Thất bại'),
  refunded('refunded', 'Hoàn tiền'),
  cancelled('cancelled', 'Đã hủy');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere((status) => status.value == value, orElse: () => PaymentStatus.pending);
  }

  bool get isPending => this == PaymentStatus.pending;
  bool get isProcessing => this == PaymentStatus.processing;
  bool get isCompleted => this == PaymentStatus.completed;
  bool get isFailed => this == PaymentStatus.failed;
  bool get isRefunded => this == PaymentStatus.refunded;
  bool get isCancelled => this == PaymentStatus.cancelled;

  bool get isSuccessful => this == PaymentStatus.completed || this == PaymentStatus.refunded;
}

