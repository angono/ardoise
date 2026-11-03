class Payment {
  final String id;
  final double amount;
  final String currency;
  final String? method;
  final String? description;
  final DateTime date;

  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    this.method,
    this.description,
    required this.date,
  });
}
