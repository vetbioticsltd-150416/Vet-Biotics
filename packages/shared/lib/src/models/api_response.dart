import 'package:vet_biotics_shared/shared.dart';

/// Generic API response wrapper
class ApiResponse<T> extends BaseModel {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  const ApiResponse({required this.success, this.message, this.data, this.error, this.statusCode, this.metadata});

  factory ApiResponse.success({String? message, T? data, int? statusCode, Map<String, dynamic>? metadata}) =>
      ApiResponse(success: true, message: message, data: data, statusCode: statusCode ?? 200, metadata: metadata);

  factory ApiResponse.error({String? message, String? error, int? statusCode, Map<String, dynamic>? metadata}) =>
      ApiResponse(success: false, message: message, error: error, statusCode: statusCode ?? 500, metadata: metadata);

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? dataFromJson) =>
      ApiResponse<T>(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String?,
        data: json['data'] != null && dataFromJson != null ? dataFromJson(json['data'] as Map<String, dynamic>) : null,
        error: json['error'] as String?,
        statusCode: json['statusCode'] as int?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  @override
  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data,
    'error': error,
    'statusCode': statusCode,
    'metadata': metadata,
  };

  @override
  String? get id => null;

  @override
  List<Object?> get props => [success, message, data, error, statusCode, metadata];

  /// Check if response is successful
  bool get isSuccessful => success && statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Check if response is client error (4xx)
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if response is server error (5xx)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has error
  bool get hasError => error != null || !success;

  /// Get error message or default message
  String get errorMessage => error ?? message ?? 'Unknown error occurred';

  /// Get success message or default message
  String get successMessage => message ?? 'Operation completed successfully';
}

/// Paginated API response
class PaginatedResponse<T> extends ApiResponse<List<T>> {
  final PaginationInfo pagination;

  const PaginatedResponse({
    required super.success,
    super.message,
    super.data,
    super.error,
    super.statusCode,
    super.metadata,
    required this.pagination,
  });

  factory PaginatedResponse.success({
    String? message,
    List<T>? data,
    required PaginationInfo pagination,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) => PaginatedResponse(
    success: true,
    message: message,
    data: data,
    pagination: pagination,
    statusCode: statusCode ?? 200,
    metadata: metadata,
  );

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) itemFromJson) {
    final data = json['data'] != null
        ? (json['data'] as List<dynamic>).map((item) => itemFromJson(item as Map<String, dynamic>)).toList()
        : null;

    final pagination = PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>? ?? {});

    return PaginatedResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: data,
      pagination: pagination,
      error: json['error'] as String?,
      statusCode: json['statusCode'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['pagination'] = pagination.toJson();
    return json;
  }

  @override
  List<Object?> get props => [...super.props, pagination];

  /// Check if there are more pages
  bool get hasNextPage => pagination.hasNextPage;

  /// Check if there are previous pages
  bool get hasPreviousPage => pagination.hasPreviousPage;

  /// Get total pages
  int get totalPages => pagination.totalPages;

  /// Get current page number
  int get currentPage => pagination.currentPage;
}
