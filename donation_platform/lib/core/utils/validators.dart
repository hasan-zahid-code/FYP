import 'package:donation_platform/config/constants.dart';

class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Use regex to validate email format
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < AppConstants.passwordMinLength) {
      return 'Password must be at least ${AppConstants.passwordMinLength} characters';
    }
    
    return null;
  }
  
  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  
  // Phone validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Basic phone validation (can be adjusted based on region)
    if (value.length < 8 || !value.contains(RegExp(r'^\+?[\d\s\-\(\)]+$'))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // CNIC validator (Pakistan National ID)
  static String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNIC is required';
    }
    
    // CNIC format: 12345-1234567-1
    final regExp = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid CNIC (format: 12345-1234567-1)';
    }
    
    return null;
  }
  
  // Organization name validator
  static String? validateOrganizationName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Organization name is required';
    }
    
    if (value.length < 3) {
      return 'Organization name must be at least 3 characters';
    }
    
    return null;
  }
  
  // Required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  // URL validator
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL can be optional
    }
    
    // Simple URL validation
    const pattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    final regExp = RegExp(pattern);
    
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // Numeric validator
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  // Amount validator
  static String? validateAmount(String? value, {double minAmount = 0}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount < minAmount) {
      return 'Amount must be at least ${minAmount.toStringAsFixed(2)}';
    }
    
    return null;
  }
  
  // Date validator
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Date cannot be in the future';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }
  
  // Postal code validator
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal code is required';
    }
    
    // Basic postal code validation (adjust based on region)
    if (value.length < 4 || !value.contains(RegExp(r'^\d{4,10}$'))) {
      return 'Please enter a valid postal code';
    }
    
    return null;
  }
}