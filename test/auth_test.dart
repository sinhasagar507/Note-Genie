import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:test/test.dart'; 

void main() {}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider
{
  var _initialized = false; 
  bool get isInitialized => _initialized;

  @override
  Future<AuthUser> createUser({required String email, required String password}) async
  {
    if(!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1),); 
    return login(email: email, password: password,); 
  }
    
  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => throw UnimplementedError();
  
  @override
  Future<void> initialize() {
  // TODO: implement initialize
  throw UnimplementedError();
  }
    
  @override
  Future<AuthUser> login({required String email, required String password}) {
  // TODO: implement login
  throw UnimplementedError();
  }
    
  @override
  Future<void> logout() {
  // TODO: implement logout
  throw UnimplementedError();
  }
    
  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
    }
}