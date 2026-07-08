abstract final class Validators {
  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(
    String? value,
    String requiredMessage,
    String invalidMessage,
  ) {
    final requiredError = required(value, requiredMessage);
    if (requiredError != null) return requiredError;

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return invalidMessage;
    }
    return null;
  }

  static String? password(
    String? value,
    String requiredMessage,
    String shortMessage,
  ) {
    final requiredError = required(value, requiredMessage);
    if (requiredError != null) return requiredError;

    if (value!.length < 6) {
      return shortMessage;
    }
    return null;
  }
}
