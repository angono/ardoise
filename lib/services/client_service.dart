import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client.dart';
import '../models/project.dart';
import '../models/payment.dart';
import '../models/app_user.dart';

class ClientService {
  final _client = Supabase.instance.client;

  Future<List<Client>> getMyClients() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('clients')
        .select('''
          id,
          company_name,
          description,
          client_access!inner(role, user_id),
          projects(budget, currency), 
          payments(amount, currency)
        ''')
        .eq('client_access.user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final accessList = json['client_access'] as List;
      final role = accessList.isNotEmpty ? accessList.first['role'] : 'client';
      final projects = json['projects'] as List? ?? [];
      final payments = json['payments'] as List? ?? [];

      // Try to get currency from the first project, then first payment, then default to EUR
      String currency = 'EUR';
      if (projects.isNotEmpty) {
        currency = projects.first['currency'] ?? 'EUR';
      } else if (payments.isNotEmpty) {
        currency = payments.first['currency'] ?? 'EUR';
      }

      final totalBudget = projects.fold<double>(
        0.0,
        (sum, p) => sum + ((p['budget'] as num?)?.toDouble() ?? 0.0),
      );
      final totalPaid = payments.fold<double>(
        0.0,
        (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0.0),
      );

      return Client(
        id: json['id'],
        companyName: json['company_name'],
        description: json['description'] ?? '',
        myRole: role,
        totalBudget: totalBudget,
        totalPaid: totalPaid,
        currency: currency,
      );
    }).toList();
  }

  Future<void> updateClient({
    required String clientId,
    required String name,
    required String description,
  }) async {
    await _client
        .from('clients')
        .update({'company_name': name, 'description': description})
        .eq('id', clientId);
  }

  // --- PROJECTS ---
  Future<List<Project>> getProjects(String clientId) async {
    final response = await _client
        .from('projects')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      return Project(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        budget: (json['budget'] as num).toDouble(),
        currency: json['currency'] ?? 'EUR', // Added currency
        url: json['url'],
        status: json['status'] ?? 'To Do',
      );
    }).toList();
  }

  Future<void> addProject({
    required String clientId,
    required String name,
    required String description,
    required double budget,
    required String currency, // Added currency
    String? url,
    required String status,
  }) async {
    await _client.from('projects').insert({
      'client_id': clientId,
      'name': name,
      'description': description,
      'budget': budget,
      'currency': currency, // Added currency
      'url': url,
      'status': status,
    });
  }

  Future<void> updateProject({
    required String projectId,
    required String name,
    required String description,
    required double budget,
    required String currency, // Added currency
    String? url,
    required String status,
  }) async {
    await _client
        .from('projects')
        .update({
          'name': name,
          'description': description,
          'budget': budget,
          'currency': currency, // Added currency
          'url': url,
          'status': status,
        })
        .eq('id', projectId);
  }

  Future<void> deleteProject(String projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }

  // --- PAYMENTS ---
  Future<List<Payment>> getPayments(String clientId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('client_id', clientId)
        .order('transaction_date', ascending: false);

    return (response as List).map((json) {
      return Payment(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] ?? 'EUR',
        method: json['payment_method'],
        description: json['description'],
        date: DateTime.parse(json['transaction_date']),
      );
    }).toList();
  }

  Future<void> addPayment({
    required String clientId,
    required double amount,
    required String currency,
    required DateTime date,
    String? method,
    String? description,
  }) async {
    await _client.from('payments').insert({
      'client_id': clientId,
      'amount': amount,
      'currency': currency,
      'transaction_date': date.toIso8601String().split('T')[0],
      'payment_method': method,
      'description': description,
    });
  }

  Future<void> updatePayment({
    required String paymentId,
    required double amount,
    required String currency,
    required DateTime date,
    String? method,
    String? description,
  }) async {
    await _client
        .from('payments')
        .update({
          'amount': amount,
          'currency': currency,
          'transaction_date': date.toIso8601String().split('T')[0],
          'payment_method': method,
          'description': description,
        })
        .eq('id', paymentId);
  }

  Future<void> deletePayment(String paymentId) async {
    await _client.from('payments').delete().eq('id', paymentId);
  }

  // --- ACCESS MANAGEMENT ---
  Future<List<AppUser>> getAllUsers() async {
    final response = await _client
        .from('profiles')
        .select('id, email, full_name')
        .order('full_name', ascending: true);

    return (response as List)
        .map(
          (json) => AppUser(
            id: json['id'],
            email: json['email'] ?? '',
            fullName: json['full_name'] ?? 'Unknown',
          ),
        )
        .toList();
  }

  Future<void> syncAccessList({
    required String clientId,
    required List<String> userIdsToKeep,
    required String grantedByUserId,
  }) async {
    final currentAccess = await _client
        .from('client_access')
        .select('id, user_id, role')
        .eq('client_id', clientId);

    final currentList = currentAccess as List;

    final idsToRemove = currentList
        .where(
          (row) =>
              row['role'] != 'owner' && !userIdsToKeep.contains(row['user_id']),
        )
        .map((row) => row['id'])
        .toList();

    final currentUserIds = currentList.map((row) => row['user_id']).toList();
    final idsToAdd = userIdsToKeep
        .where((id) => !currentUserIds.contains(id))
        .toList();

    if (idsToRemove.isNotEmpty) {
      await _client.from('client_access').delete().inFilter('id', idsToRemove);
    }

    if (idsToAdd.isNotEmpty) {
      final newRows = idsToAdd
          .map(
            (userId) => {
              'client_id': clientId,
              'user_id': userId,
              'role': 'client',
              'granted_by': grantedByUserId,
            },
          )
          .toList();
      await _client.from('client_access').insert(newRows);
    }
  }
}
