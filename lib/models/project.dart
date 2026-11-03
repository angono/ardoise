class Project {
  final String id;
  final String name;
  final String description;
  final double budget;
  final String currency; // Added currency
  final String? url;
  final String status;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.budget,
    this.currency = 'EUR', // Default to EUR
    this.url,
    this.status = 'To Do',
  });
}
