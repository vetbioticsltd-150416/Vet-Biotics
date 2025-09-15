import 'base_entity.dart';

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

  static InvoiceStatus fromString(String value) =>
      InvoiceStatus.values.firstWhere((status) => status.value == value, orElse: () => InvoiceStatus.draft);

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

  static PaymentMethod fromString(String value) =>
      PaymentMethod.values.firstWhere((method) => method.value == value, orElse: () => PaymentMethod.cash);
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

  Invoice({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
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
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

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
  bool get isValid =>
      invoiceNumber.isNotEmpty &&
      clinicId.isNotEmpty &&
      customerId.isNotEmpty &&
      items.isNotEmpty &&
      subtotal >= 0 &&
      totalAmount >= 0;

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

  @override
  Invoice copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
  }) => Invoice(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    invoiceNumber: invoiceNumber,
    clinicId: clinicId,
    customerId: customerId,
    petId: petId,
    appointmentId: appointmentId,
    status: status,
    issueDate: issueDate,
    dueDate: dueDate,
    items: items,
    subtotal: subtotal,
    taxRate: taxRate,
    taxAmount: taxAmount,
    discountAmount: discountAmount,
    totalAmount: totalAmount,
    notes: notes,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'invoiceNumber': invoiceNumber,
    'clinicId': clinicId,
    'customerId': customerId,
    'petId': petId,
    'appointmentId': appointmentId,
    'status': status.value,
    'issueDate': issueDate.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'taxRate': taxRate,
    'taxAmount': taxAmount,
    'discountAmount': discountAmount,
    'totalAmount': totalAmount,
    'notes': notes,
    'metadata': metadata,
  };

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

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    serviceId: json['serviceId'] as String,
    serviceName: json['serviceName'] as String,
    description: json['description'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 1,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    totalPrice: (json['totalPrice'] as num).toDouble(),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'serviceName': serviceName,
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'metadata': metadata,
  };

  InvoiceItem copyWith({
    String? serviceId,
    String? serviceName,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    Map<String, dynamic>? metadata,
  }) => InvoiceItem(
    serviceId: serviceId ?? this.serviceId,
    serviceName: serviceName ?? this.serviceName,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    totalPrice: totalPrice ?? this.totalPrice,
    metadata: metadata ?? this.metadata,
  );
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

  Payment({
    super.id = '',
    DateTime? createdAt,
    DateTime? updatedAt,
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
  }) : super(createdAt: createdAt ?? DateTime.now(), updatedAt: updatedAt ?? DateTime.now());

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
  bool get isValid => invoiceId.isNotEmpty && customerId.isNotEmpty && amount > 0;

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

  @override
  Payment copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
  }) => Payment(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    invoiceId: invoiceId,
    customerId: customerId,
    amount: amount,
    method: method,
    status: status,
    paymentDate: paymentDate,
    transactionId: transactionId,
    referenceNumber: referenceNumber,
    notes: notes,
    paymentDetails: paymentDetails,
    metadata: metadata,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isActive': isActive,
    'invoiceId': invoiceId,
    'customerId': customerId,
    'amount': amount,
    'method': method.value,
    'status': status.value,
    'paymentDate': paymentDate?.toIso8601String(),
    'transactionId': transactionId,
    'referenceNumber': referenceNumber,
    'notes': notes,
    'paymentDetails': paymentDetails,
    'metadata': metadata,
  };
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

  static PaymentStatus fromString(String value) =>
      PaymentStatus.values.firstWhere((status) => status.value == value, orElse: () => PaymentStatus.pending);

  bool get isPending => this == PaymentStatus.pending;
  bool get isProcessing => this == PaymentStatus.processing;
  bool get isCompleted => this == PaymentStatus.completed;
  bool get isFailed => this == PaymentStatus.failed;
  bool get isRefunded => this == PaymentStatus.refunded;
  bool get isCancelled => this == PaymentStatus.cancelled;

  bool get isSuccessful => this == PaymentStatus.completed || this == PaymentStatus.refunded;
}
