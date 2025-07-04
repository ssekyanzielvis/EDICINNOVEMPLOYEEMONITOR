import '../entities/admin.dart';

abstract class AdminRepository {
  Future<Admin?> getAdmin(String id);
  Future<Admin> insertAdmin(Admin admin);
}
