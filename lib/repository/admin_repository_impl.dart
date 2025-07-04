import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/admin.dart';
import '../models/admin_models.dart';
import 'admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _client;

  AdminRepositoryImpl(this._client);

  @override
  Future<Admin?> getAdmin(String id) async {
    try {
      final response =
          await _client.from('admins').select().eq('id', id).maybeSingle();

      if (response == null) return null;
      return AdminModel.fromMap(response).toEntity();
    } catch (e) {
      throw Exception('Failed to fetch admin: $e');
    }
  }

  @override
  Future<Admin> insertAdmin(Admin admin) async {
    try {
      final adminModel = AdminModel.fromEntity(admin);
      final response =
          await _client
              .from('admins')
              .insert(adminModel.toMap())
              .select()
              .single();

      return AdminModel.fromMap(response).toEntity();
    } catch (e) {
      throw Exception('Failed to insert admin: $e');
    }
  }
}
