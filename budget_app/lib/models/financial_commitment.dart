import 'dart:math';

class FinancialCommitment {
  final String id;
  final String name;
  final String categoryId;
  final String subcategoryId;
  final double monthlyAmount;
  final double totalAmount;
  final double paidAmount;
  final double remainingBalance;
  final DateTime startDate;
  final DateTime nextPaymentDate;
  final int paymentDay;
  final int totalInstallments;
  final int paidInstallments;
  final bool isActive;
  final DateTime createdAt;
  final List<String> paidPaymentKeys;

  FinancialCommitment({
    String? id,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    required this.monthlyAmount,
    required this.totalAmount,
    required double paidAmount,
    double? remainingBalance,
    required this.startDate,
    required this.nextPaymentDate,
    required this.paymentDay,
    required this.totalInstallments,
    required int paidInstallments,
    this.isActive = true,
    DateTime? createdAt,
    List<String>? paidPaymentKeys,
  })  : assert(monthlyAmount > 0),
        assert(totalAmount >= monthlyAmount),
        assert(paymentDay >= 1 && paymentDay <= 31),
        id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        paidAmount = max(paidAmount, 0),
        remainingBalance =
            remainingBalance ?? max(totalAmount - max(paidAmount, 0), 0),
        paidInstallments = min(max(paidInstallments, 0), totalInstallments),
        createdAt = createdAt ?? DateTime.now(),
        paidPaymentKeys = List.unmodifiable(paidPaymentKeys ?? const []);

  FinancialCommitment copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? subcategoryId,
    double? monthlyAmount,
    double? totalAmount,
    double? paidAmount,
    double? remainingBalance,
    DateTime? startDate,
    DateTime? nextPaymentDate,
    int? paymentDay,
    int? totalInstallments,
    int? paidInstallments,
    bool? isActive,
    DateTime? createdAt,
    List<String>? paidPaymentKeys,
  }) {
    return FinancialCommitment(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingBalance: remainingBalance,
      startDate: startDate ?? this.startDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      paymentDay: paymentDay ?? this.paymentDay,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      paidPaymentKeys: paidPaymentKeys ?? this.paidPaymentKeys,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'monthlyAmount': monthlyAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingBalance': remainingBalance,
      'startDate': startDate.toIso8601String(),
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'paymentDay': paymentDay,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'paidPaymentKeys': paidPaymentKeys,
    };
  }

  factory FinancialCommitment.fromMap(Map<String, dynamic> map) {
    final total = _readDouble(map['totalAmount']);
    final paid = _readDouble(map['paidAmount']);
    final monthly = _readDouble(map['monthlyAmount']);
    final installments = _readInt(map['totalInstallments'], fallback: 1);

    return FinancialCommitment(
      id: map['id'] as String?,
      name: map['name'] as String? ?? 'Compromiso',
      categoryId: map['categoryId'] as String? ?? 'general',
      subcategoryId: map['subcategoryId'] as String? ?? 'other',
      monthlyAmount: monthly <= 0 ? 1 : monthly,
      totalAmount: total < monthly ? monthly : total,
      paidAmount: paid,
      remainingBalance: _readDoubleOrNull(map['remainingBalance']),
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ??
          DateTime.now(),
      nextPaymentDate:
          DateTime.tryParse(map['nextPaymentDate'] as String? ?? '') ??
              DateTime.now(),
      paymentDay: _readInt(map['paymentDay'], fallback: DateTime.now().day)
          .clamp(1, 31),
      totalInstallments: installments,
      paidInstallments: _readInt(map['paidInstallments'], fallback: 0),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      paidPaymentKeys:
          (map['paidPaymentKeys'] as List?)?.whereType<String>().toList() ??
              const [],
    );
  }

  static double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _readDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
