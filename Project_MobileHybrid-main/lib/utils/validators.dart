class Validators {
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!value!.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 6) {
      return 'Password must be 6+ characters';
    }
    return null;
  }
  static String? validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Name is required';
    }
    if (value!.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
  static String? validateContent(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Content cannot be empty';
    }
    if (value!.length > 500) {
      return 'Content must be 500 characters or less';
    }
    return null;
  }
}
