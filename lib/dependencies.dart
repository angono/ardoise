import 'services/auth_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/client_service.dart';

final AuthService authService = SupabaseAuthService();
final ClientService clientService = ClientService();
