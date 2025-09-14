import 'package:shared/src/models/base_model.dart';

/// Pagination information
class PaginationInfo extends BaseModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
      totalItems: json['totalItems'] as int? ?? 0,
      itemsPerPage: json['itemsPerPage'] as int? ?? 20,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  @override
  List<Object?> get props => [currentPage, totalPages, totalItems, itemsPerPage, hasNextPage, hasPreviousPage];

  /// Calculate pagination info
  factory PaginationInfo.calculate({required int currentPage, required int totalItems, required int itemsPerPage}) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    final hasNextPage = currentPage < totalPages;
    final hasPreviousPage = currentPage > 1;

    return PaginationInfo(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: hasNextPage,
      hasPreviousPage: hasPreviousPage,
    );
  }

  /// Get the offset for database queries
  int get offset => (currentPage - 1) * itemsPerPage;

  /// Get the limit for database queries
  int get limit => itemsPerPage;
}

/// Pagination parameters for API requests
class PaginationParams {
  final int page;
  final int limit;
  final String? sortBy;
  final String? sortOrder; // 'asc' or 'desc'
  final Map<String, dynamic>? filters;

  const PaginationParams({this.page = 1, this.limit = 20, this.sortBy, this.sortOrder, this.filters});

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{'page': page.toString(), 'limit': limit.toString()};

    if (sortBy != null) {
      params['sortBy'] = sortBy;
    }

    if (sortOrder != null) {
      params['sortOrder'] = sortOrder;
    }

    if (filters != null) {
      params.addAll(filters!);
    }

    return params;
  }

  PaginationParams copyWith({int? page, int? limit, String? sortBy, String? sortOrder, Map<String, dynamic>? filters}) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filters: filters ?? this.filters,
    );
  }

  @override
  String toString() {
    return 'PaginationParams(page: $page, limit: $limit, sortBy: $sortBy, sortOrder: $sortOrder, filters: $filters)';
  }
}
