import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/services/auth/auth_exception.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider(); 
    
    // Test if the user is initialized
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false); 
    }); 

    // Test if the user can be logged out 
    test('Cannot logout if not initialized', () {
      expect(
        provider.logout(), 
        throwsA(const TypeMatcher<NotInitializedException>()) 
      ); 
    },);

    // Test if the user can be initialized in a particular time frame 
    test('Should be able to initialize in less than 2 secs', () async{
      await provider.initialize(); 
      expect(provider.isInitialized, true); 
    }, 
    timeout: const Timeout(Duration(seconds: 2)),
    ); 

    // Test creating a user 
    test('Create user should delegate to login function', () async {
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'foobar',);

      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>())); 

      final badPasswordUser = provider.createUser(email: 'someone@bar.com', password: 'foobar',); 
      expect(badPasswordUser, 
      throwsA(const TypeMatcher<WrongPasswordAuthException>())); 

      final user = await provider.createUser(email: 
      'foo', password: 'bar',); 

      expect(provider.currentUser, user); 
      expect(user.isEmailVerified, false); 
    });

    // Test email verification 
    
  }); 
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider
{
  AuthUser? _user; 
  var _isInitialized = false; 
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({required String email, required String password}) async
  {
    if(!isInitialized) throw NotInitializedException(); // This is to test if my mock AuthProvider is initialized 
    await Future.delayed(const Duration(seconds: 1),); 
    return login(email: email, password: password,); 
  }
    
  @override
  AuthUser? get currentUser => _user;
  
  @override
  Future<void> initialize() async{
  await Future.delayed(const Duration(seconds: 1),);
  _isInitialized = true; 
  }
    
  @override
  Future<AuthUser> login({required String email, required String password}) {
  if (!isInitialized) throw NotInitializedException();
  if (email == 'foo@bar.com') throw UserNotFoundAuthException(); 
  if (password == 'foobar') throw WrongPasswordAuthException(); 
  const user = AuthUser(isEmailVerified: false); 
  _user = user; 
  return Future.value(user); 
  }
    
  @override
  Future<void> logout() async{
  if (!isInitialized) throw NotInitializedException();
  if(_user == null) throw UserNotFoundAuthException(); 
  await Future.delayed(const Duration(seconds: 1),); 
  _user = null; 
  }
    
  @override
  Future<void> sendEmailVerification() async {
    // TODO: implement sendEmailVerification
    // if (!isInitialized) throw NotInitializedException();
    // final user = _user; 
    // if(user == null) throw UserNotFoundAuthException(); 
    // final newUser = AuthUser(isEmailVerified: true), 
    // _user = newUser; 
    throw UnimplementedError(); 
    }
}