import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/services/auth/auth_exception.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    /** 
    Test if the user is initialized
    Now here I have assumed that the mock auth provider shouldn't be initialized to begin with 
    Hence I expect the value to be false 
    **/
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    // Test if the user can be logged out
    test(
      'Cannot logout if not initialized',
      () {
        expect(
            provider.logout(), // the auth service provider will logout the user
            /*
        A function that throws an exception when called. The function cannot take any arguments,
        and id the function has arguments, I need to wrap the function with arguments in the original function 
        which contains the test 
        */
            throwsA(const TypeMatcher<
                NotInitializedException>()) // this will be executed if no user is initialized
            );
      },
    );

    // Test if the user can be initialized in a particular time frame
    // I am calling the provider.initialize() of the mock auth provider and I want to test in how much time frame my value is returned exactly
    // If the initialization isn't happened in less than 2 seconds, the test will fail
    test(
      'Should be able to initialize in less than 2 secs',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(
        Duration(seconds: 2),
      ),
    );

    // Test creating a user
    // Now there will be some particular users
    test('Create user should delegate to login function', () async {
      /*
      Here firebase isn't coming into the picture, I am just creating a mock user with a particular email and password 
      I have already provided that particular username and password as bad emails and passwords and I expect the test 
      to throw and exception if I pass in those IDs 
      */

      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'foobar',
      );
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: 'someone@bar.com',
        password: 'foobar',
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false); // I expect the user's email
    });

    // Test email verification
    test("Logged in user should be able to get verified", () {
      provider.sendEmailVerification();
      // Now I want to test that the provider doesn't return a null user
      final user = provider.currentUser;
      expect(user, isNotNull);

      /*
      Now, since the user is logged in, I also want to test that the user is logged in, I am setting it to verified. 

      */
      expect(user!.isEmailVerified, true);
    });

    // In the next test, the user should be able to logout and login again
    test('User should be able to logout and login again', () async {
      await provider.logout();
      await provider.login(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  // Here I am creating a getter function such that I can access the value of the variable outside its limited scope through this function
  bool get isInitialized => _isInitialized;

  @override
  /**
   * This method simulates actual user creation. It checks if a provider is initialized, introduces a delay
   * It simulates the process of creating a new user in the context of a mock authentication provider 
   * 
   * @param email - The email of the user to be created
   * @param password - The password of the new user 
*
   * The `createUser` method performs the following operations:
   * 
   * 1. **Initialization Check**:
   *    - The first operation is to check whether the mock authentication provider has been initialized.
   *    - If the provider is not initialized (`_isInitialized` is false), it throws a `NotInitializedException`.
   *    - This ensures that user creation can only proceed if the provider is properly set up, simulating real-world 
   *      scenarios where services must be initialized before they can be used.
   *
   * 2. **Simulated Processing Delay**:
   *    - The method introduces an artificial delay of 1 second using `Future.delayed`.
   *    - This delay simulates network latency or other processing time that might occur in a real-world user 
   *      creation process, allowing the test environment to mimic more realistic conditions.
   *
   * 3. **Delegation to Login Method**:
   *    - After the initialization check and delay, the method calls the `login` method to handle the actual user 
   *      creation.
   *    - This means that `createUser` in this mock provider is essentially a wrapper around the `login` method, 
   *      first ensuring the provider is ready and then proceeding with the login process.
   *    - This approach simplifies the code by reusing the `login` logic for both user creation and authentication.
   * 
   * **Conclusion**:
   * The `createUser` method is an essential part of the mock authentication provider, ensuring that only 
   * initialized providers can create users and introducing a delay to simulate real-world conditions. 
   * It also demonstrates code reuse by delegating the actual user creation to the `login` method.
  **/

  /**
   * This method is an override of the `createUser` method from the `AuthProvider` interface or superclass.
   * It simulates the process of creating a new user in the context of a mock authentication provider.
   *
   * @param email - The email of the user to be created. This is a required parameter.
   * @param password - The password for the new user. This is also a required parameter.
   *
   * The `createUser` method performs the following operations:
   * 
   * 1. **Initialization Check**:
   *    - The method begins by checking if the mock authentication provider has been initialized.
   *    - If the provider is not initialized (`_isInitialized` is false), it throws a `NotInitializedException`.
   *    - This check ensures that the user creation process cannot proceed unless the service is ready, 
   *      simulating the need for proper setup in a real authentication system.
   *
   * 2. **Simulated Processing Delay**:
   *    - The method introduces an artificial delay of 1 second using `Future.delayed`.
   *    - This delay simulates the time that might be required to process a user creation request in a real-world 
   *      scenario, such as network latency or server-side processing.
   *    - This helps to create a more realistic environment for testing, where certain operations are expected 
   *      to take time.
   *
   * 3. **Delegation to Login Method**:
   *    - After the initialization check and delay, the method delegates the task of user creation to the `login` method.
   *    - The `login` method is responsible for handling the actual user creation, verifying the credentials, 
   *      and returning an authenticated user.
   *    - By reusing the `login` logic for both creating and authenticating users, the code is simplified and 
   *      ensures consistency in how users are handled within the mock provider.
   * 
   * **Conclusion**:
   * The `createUser` method is essential for simulating user creation within the mock authentication provider. 
   * It ensures that the provider is properly initialized before proceeding with user creation, introduces a delay 
   * to mimic real-world conditions, and efficiently reuses the `login` method to handle the actual creation process. 
   * This makes it a crucial part of the testing framework, allowing developers to test various scenarios related to 
   * user creation and authentication.
   */
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(
      const Duration(seconds: 1),
    );
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  /**
   * This method is an override of the `initialize` method from the `AuthProvider` interface or superclass.
   * It simulates the initialization process of the authentication service within the mock provider.
   *
   * The `initialize` method performs the following key operations:
   * 
   * 1. **Simulating Initialization**:
   *    - This method simulates the setup or initialization phase of an authentication service.
   *    - In a real-world scenario, this could involve establishing a connection to an authentication server, 
   *      loading configuration files, setting up necessary resources, or performing any other preparatory tasks 
   *      required before the service can be used.
   *
   * 2. **Introducing a Deliberate Delay**:
   *    - The `Future.delayed` function introduces an artificial delay of 1 second.
   *    - This delay is used to simulate a time-consuming initialization process, such as connecting to a remote 
   *      server or performing a resource-intensive task.
   *    - This delay helps create a more realistic testing environment by mimicking real-world scenarios where 
   *      initialization might take some time.
   *    - For instance, the delay could represent the time it takes to make an API call and receive a response 
   *      before the service can be marked as initialized.
   *
   * 3. **Setting the Initialization Flag**:
   *    - After the 1-second delay, the `_isInitialized` flag is set to `true`.
   *    - This flag indicates that the mock authentication provider has completed its initialization process 
   *      and is now ready for use.
   *    - Other methods within the mock provider, such as `login` or `createUser`, may check this flag to ensure 
   *      that the provider is initialized before they proceed with their respective operations.
   *    - This helps to simulate the behavior of a real authentication service, where certain operations are 
   *      not allowed until the service is fully set up and ready.
   * 
   * **Conclusion**:
   * The `initialize` method is crucial for simulating the initialization process of the mock authentication provider. 
   * It introduces a delay to mimic real-world initialization times and sets an internal flag to indicate that 
   * the provider is ready for use. This ensures that tests involving this mock provider can accurately reflect 
   * scenarios where the initialization process is necessary and potentially time-consuming.
   */
  Future<void> initialize() async {
    // The initialization method simulates the setup or initialization of the authentication service.
    // This could represent establishing a connection to an authentication server or loading necessary resources.
    await Future.delayed(const Duration(
        seconds:
            1)); // Introduce an artificial 1-second delay to simulate a time-consuming initialization process.

    // After the delay, the `_isInitialized` flag is set to `true`, indicating that the mock provider is now ready for use.
    _isInitialized = true;
  }

  /**
   * This method is an override of the `login` method from the `AuthProvider` interface or superclass.
   * It simulates the login process for a user in the context of a mock authentication provider.
   *
   * @param email - The email of the user attempting to log in. This is a required parameter.
   * @param password - The password of the user attempting to log in. This is also a required parameter.
   *
   * The `login` method performs the following key operations:
   * 
   * 1. **Initialization Check**:
   *    - The first operation checks whether the mock authentication provider has been initialized.
   *    - If the provider is not initialized (`_isInitialized` is false), it throws a `NotInitializedException`.
   *    - This ensures that the `login` method cannot be executed unless the provider is ready, simulating 
   *      real-world scenarios where services must be properly set up before being used.
   *
   * 2. **Simulating Authentication Errors**:
   *    - The next two conditions simulate common authentication errors:
   *      - If the email provided matches `foo@bar.com`, a `UserNotFoundAuthException` is thrown. This simulates 
   *        a scenario where a user tries to log in with an email that does not exist in the system.
   *      - If the password provided matches `foobar`, a `WrongPasswordAuthException` is thrown. This simulates 
   *        a scenario where a user provides an incorrect password for an existing email.
   *    - These checks are essential for testing how the application handles different types of login failures.
   *
   * 3. **Creating an Authenticated User**:
   *    - If the email and password do not trigger any of the exceptions above, a new `AuthUser` is created.
   *    - The `AuthUser` is initialized with `isEmailVerified` set to `false`, indicating that the user has 
   *      not yet verified their email.
   *    - The `_user` variable, which stores the current authenticated user in the mock provider, is then 
   *      updated to reference this new `AuthUser`.
   *
   * 4. **Returning the Authenticated User**:
   *    - Finally, the method returns the newly created `AuthUser` wrapped in a `Future`.
   *    - The use of `Future.value(user)` indicates that the user creation process is completed instantly 
   *      in this simulation, unlike in a real-world scenario where this might involve network communication 
   *      and thus take time.
   * 
   * This `login` method is crucial for simulating user authentication in a controlled test environment.
   * It allows the developer to test various authentication scenarios, including successful logins, 
   * initialization checks, and handling of incorrect credentials.
   */

  /** 
   * The following method is an override of the login method provided in MockAuthProvider. 
   * 
   * @param email - The email of the user I am trying to logging in 
   * @param password - The email of the password I am trying to logging in 
   * 
   * 1. **Initialization Check** 
   *  - The first and foremost thing of entering is to check if the MockAuthProvider is initialized 
   * 
   * 2. **Dummy email and password creation** 
   *   - Thereafter, I created a dummy email and password which I don't like and would like the 
   *     mock provider to throw an Exception if either of those email or password is provided 
   *
   * 3. **Mock user login and make mark if its email is verified as false** 
   *    - Thereafter, the value of usr is passed onto as the current user and I am returning that particular mock user to the 
   *      Future.value such that it is initialized. Return the user wrapped in a Future 
   * 4. **Returning the user** 
   *    - Finally, I return the user as an instance of Future.value() since the user is being mocked and isn't returned instantaneously 
   *      in the normal scenario. 
   * 
   */
  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!isInitialized)
      throw NotInitializedException(); // Check if the provider is initialized, otherwise throw an exception
    if (email == 'foo@bar.com')
      throw UserNotFoundAuthException(); // Simulate user not found error
    if (password == 'foobar')
      throw WrongPasswordAuthException(); // Simulate wrong password error
    const user = AuthUser(
      email: 'foo@bar.com',
      isEmailVerified: false,
    ); // Create a new user with email verification set to false
    _user = user; // Update the current user to this newly created user
    return Future.value(user); // Return the user wrapped in a Future
  }

  /*
  Finally, the user who is already logged in also needs to be logged out
  So, if the user is already null, I would throw an Exception. And if its not, I would delay the process like how its in 
  real-world scenarios and then I set the value of current user to null 
  */
  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(
      const Duration(seconds: 1),
    );
    _user = null;
  }

  // Here I would try to mock email verification

  @override
  Future<void> sendEmailVerification() async {
    // TODO: implement send EmailVerification
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    final newUser = AuthUser(
      email: 'foo@bar.com',
      isEmailVerified: true,
    );
    // I will introduce an artificial delay since the backend is checking for user verification
    _user = newUser;
  }
}
