import 'package:secondflutter/services/auth/auth_exceptions.dart';
import 'package:secondflutter/services/auth/auth_provider.dart';
import 'package:secondflutter/services/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Moch Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NoteInitializeAppException>()));
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test('Should be able to be initialized in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('CReatse user should delegate to logIn function', () async {
      final badEmailUser =
          provider.createUser(email: 'car@ol.com', password: 'anypassword');
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFound>()));
      final badPasswordUser =
          provider.createUser(email: 'someone@som.com', password: 'carol');
      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPassword>()));
      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('logged in user should be able to get veriied', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NoteInitializeAppException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NoteInitializeAppException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NoteInitializeAppException();
    if (email == 'car@ol.com') throw UserNotFound();
    if (password == 'carol') throw WrongPassword();
    const user = AuthUser(isEmailVerified: false, email: 'car@rol.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NoteInitializeAppException();
    if (_user == null) throw UserNotFound();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NoteInitializeAppException();
    final user = _user;
    if (user == null) throw UserNotFound();
    const newUser = AuthUser(isEmailVerified: true, email: 'car@rol.com');
    _user = newUser;
  }
}
