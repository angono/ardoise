class Currency {
  final String code;
  final String symbol;
  final String name;
  const Currency(this.code, this.symbol, this.name);
}

class AppConstants {
  static const List<String> projectStatuses = [
    'To Do',
    'In Progress',
    'Completed',
  ];

  static const List<Currency> currencies = [
    Currency('EUR', '€', 'Euro'),
    Currency('USD', '\$', 'US Dollar'),
    Currency('GBP', '£', 'British Pound'),
    Currency('XAF', 'FCFA', 'Central African CFA'),
    Currency('XOF', 'CFA', 'West African CFA'),
    Currency('CAD', 'C\$', 'Canadian Dollar'),
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Mobile Money',
    'Western Union',
    'Credit/Debit Card',
    'Other',
  ];
}
