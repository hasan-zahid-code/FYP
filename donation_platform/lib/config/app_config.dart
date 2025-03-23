import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  
  // Maps API Key
  static String get mapsApiKey => dotenv.env['MAPS_API_KEY'] ?? '';
  
  // Feature Flags
  static bool get enableNotifications => dotenv.env['ENABLE_NOTIFICATIONS'] == 'true';
  static bool get enableLocationServices => dotenv.env['ENABLE_LOCATION_SERVICES'] == 'true';
  
  // App Settings
  static String get appName => 'Donation Platform';
  static String get appVersion => '1.0.0';
  static String get buildNumber => '1';
  
  // Timeouts
  static int get connectionTimeout => 30000; // 30 seconds
  static int get receiveTimeout => 30000; // 30 seconds
  
  // Pagination
  static int get defaultPageSize => 20;
}