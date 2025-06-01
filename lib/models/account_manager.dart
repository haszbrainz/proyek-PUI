class AccountManager {
  static String? registeredEmail;
  static String? registeredPassword;

  static bool login(String email, String password) {
    return registeredEmail == email && registeredPassword == password;
  }

  static void register(String email, String password) {
    registeredEmail = email;
    registeredPassword = password;
  }
}
