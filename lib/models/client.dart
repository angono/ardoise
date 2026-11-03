class Client {
  final String id;
  final String companyName;
  final String description;
  final String myRole;
  final double totalBudget;
  final double totalPaid;
  final String currency; // Added currency

  const Client({
    required this.id,
    required this.companyName,
    required this.description,
    required this.myRole,
    required this.totalBudget,
    required this.totalPaid,
    this.currency = 'EUR', // Default
  });

  double get balance => totalBudget - totalPaid;
  bool get isOwner => myRole == 'owner';
}
