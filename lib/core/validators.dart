/// Centralized input validation and sanitization utilities
/// for production-ready input handling across the application.

/// Static validators for common input types
class InputValidators {
  InputValidators._();

  /// Email regex pattern
  static final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Malaysian phone number pattern
  /// Supports: 01X-XXXXXXX, 01X-XXXXXXXX, +601X-XXXXXXX, 601X-XXXXXXX
  static final _phoneRegex = RegExp(r'^(\+?6?01[0-9]{8,9}|01[0-9]{8,9})$');

  /// Name validation - allows letters, spaces, hyphens, apostrophes
  static final _nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate phone number (Malaysian format)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Remove spaces and dashes for validation
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid phone number (e.g., 012-3456789)';
    }
    return null;
  }

  /// Validate name field
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmed.length > 100) {
      return 'Name is too long (max 100 characters)';
    }
    if (!_nameRegex.hasMatch(trimmed)) {
      return 'Name contains invalid characters';
    }
    return null;
  }

  /// Validate guest count within bounds
  static String? validateGuestCount(int count, {int min = 1, int max = 35}) {
    if (count < min) {
      return 'At least $min guest is required';
    }
    if (count > max) {
      return 'Maximum $max guests allowed';
    }
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value, {bool requireStrong = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (requireStrong) {
      if (!RegExp(r'[A-Z]').hasMatch(value)) {
        return 'Password must contain an uppercase letter';
      }
      if (!RegExp(r'[0-9]').hasMatch(value)) {
        return 'Password must contain a number';
      }
    }
    return null;
  }

  /// Validate passwords match
  static String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }
}

/// Static sanitizers for cleaning user input
class InputSanitizers {
  InputSanitizers._();

  /// Characters that could be used for injection attacks
  static final _dangerousChars = RegExp(r'[<>"\x27;\\]');

  /// Sanitize general text input
  /// - Trims whitespace
  /// - Removes potentially dangerous characters
  /// - Limits length
  static String sanitizeText(String input, {int maxLength = 500}) {
    String sanitized = input.trim();
    sanitized = sanitized.replaceAll(_dangerousChars, '');
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }

  /// Sanitize phone number - remove all non-numeric chars except +
  static String sanitizePhone(String input) {
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Sanitize email - lowercase and trim
  static String sanitizeEmail(String input) {
    return input.trim().toLowerCase();
  }

  /// Sanitize name - remove extra spaces, capitalize words
  static String sanitizeName(String input) {
    String sanitized = input.trim();
    // Replace multiple spaces with single space
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    // Remove dangerous characters
    sanitized = sanitized.replaceAll(_dangerousChars, '');
    return sanitized;
  }

  /// Sanitize special requests / comments
  /// More permissive but still safe
  static String sanitizeSpecialRequests(String input, {int maxLength = 1000}) {
    String sanitized = input.trim();
    // Only remove the most dangerous chars for free-form text
    sanitized = sanitized.replaceAll(RegExp(r'[<>]'), '');
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    return sanitized;
  }
}
