class ClientAccessMember {
  final String accessId;
  final String userId;
  final String email;
  final String fullName;
  final String role; // 'owner' or 'client'

  const ClientAccessMember({
    required this.accessId,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  bool get isOwner => role == 'owner';
}
