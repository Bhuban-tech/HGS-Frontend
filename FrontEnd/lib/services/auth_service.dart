import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/auth_response.dart';
import 'package:HamroGharSewa/repositories/auth_repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AuthRepository? _repository;

  void initialize() {
    if (_repository != null) return; 

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _repository = AuthRepository(dio);
  }

  AuthRepository get _ensureRepository {
    if (_repository == null) {
      initialize();
    }
    return _repository!;
  }

  Future<AuthResponse> login(String email, String password) {
    return _ensureRepository.login(email, password);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return _ensureRepository.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }

  Future<AuthResponse> verifyOtp(String email, String otp) {
    return _ensureRepository.verifyOtp(email, otp);
  }

  Future<void> logout() async {
    await _ensureRepository.logout();
  }

  Future<dynamic> resetPassword({required String email, required String otp, required String newPassword}) async {}

  Future<dynamic> forgotPassword(String email) async {}
}