class Payment {
  final String id;
  final String courseName;
  final String studentId;
  final String studentName;
  final double amount;
  final PaymentStatus status;

  // Time-related fields
  final DateTime createdAt; // when payment was initiated
  final DateTime? updatedAt; // when status last changed
  final DateTime? paidAt; // when payment was accepted

  Payment({
    required this.id,
    required this.courseName,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paidAt,
  });

  Payment copyWith({
    String? courseName,
    String? studentId,
    String? studentName,
    double? amount,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
  }) {
    return Payment(
      id: id,
      courseName: courseName ?? this.courseName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

enum PaymentStatus { accepted, pending, rejected }
