import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/config/app_config.dart';
import 'package:donation_platform/core/utils/exceptions.dart';
import 'package:donation_platform/config/constants.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _baseUrl;
  
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;
  
  // Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _getHeaders(headers),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(AppConstants.connectionErrorMessage);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
  
  // Generic POST request
  Future<dynamic> post(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _getHeaders(headers),
        body: jsonEncode(data),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(AppConstants.connectionErrorMessage);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
  
  // Generic PUT request
  Future<dynamic> put(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _getHeaders(headers),
        body: jsonEncode(data),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(AppConstants.connectionErrorMessage);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
  
  // Generic PATCH request
  Future<dynamic> patch(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _getHeaders(headers),
        body: jsonEncode(data),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(AppConstants.connectionErrorMessage);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
  
  // Generic DELETE request
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: await _getHeaders(headers),
      ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(AppConstants.connectionErrorMessage);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to connect to server: ${e.toString()}');
    }
  }
  
  // File upload
  Future<dynamic> uploadFile(String endpoint, File file, {String? fileField, Map<String, String>? fields, Map<String, String>? headers}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/$endpoint'));
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        fileField ?? 'file',
        file.path,
      ));
      
      // Add additional fields if provided
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Add headers
      request.headers.addAll(await _getHeaders(headers));
      
      // Send request
      final streamedResponse = await request.send().timeout(Duration(milliseconds: AppConfig.connectionTimeout));
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException(AppConstants.connectionErrorMessage);
    } on TimeoutException {
      throw NetworkException('Request timed out. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to upload file: ${e.toString()}');
    }
  }
  
  // Handle response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized. Please login again.');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('You don\'t have permission to access this resource.');
    } else if (response.statusCode == 404) {
      throw NotFoundException('The requested resource was not found.');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? AppConstants.defaultErrorMessage;
        throw ApiException(errorMessage, response.statusCode);
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        throw ApiException(AppConstants.defaultErrorMessage, response.statusCode);
      }
    }
  }
  
  // Get headers including auth token
  Future<Map<String, String>> _getHeaders(Map<String, String>? additionalHeaders) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add auth token if available
    final session = _supabase.auth.currentSession;
    if (session != null) {
      headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    
    // Add additional headers if provided
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }
  
  // Supabase direct queries (for when you need more control or real-time features)
  SupabaseClient get supabase => _supabase;
}