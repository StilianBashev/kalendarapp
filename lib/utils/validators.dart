class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Въведете имейл';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Невалиден имейл';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Въведете парола';
    if (value.length < 6) return 'Паролата трябва да е минимум 6 символа';
    return null;
  }

  static String? validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Това поле е задължително';
    }
    return null;
  }
}
