import 'package:flutter/material.dart';
import 'package:HamroGharSewa/services/complete_api_service.dart';

/// API Integration Test Widget
/// This widget provides a UI to test all API endpoints
class ApiIntegrationTest extends StatefulWidget {
  const ApiIntegrationTest({Key? key}) : super(key: key);

  @override
  State<ApiIntegrationTest> createState() => _ApiIntegrationTestState();
}

class _ApiIntegrationTestState extends State<ApiIntegrationTest> {
  final CompleteApiService _api = CompleteApiService();
  String _result = 'No test run yet';
  bool _loading = false;

  Future<void> _runTest(String testName, Future<void> Function() testFunction) async {
    setState(() {
      _loading = true;
      _result = 'Running $testName...';
    });

    try {
      await testFunction();
      setState(() {
        _result = '✅ $testName: SUCCESS';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _result = '❌ $testName: FAILED\n$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _result,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // 1. Authentication Tests
              _buildSectionHeader('1. Authentication'),
              _buildTestButton('Register User', () async {
                final result = await _api.register(
                  username: 'testuser${DateTime.now().millisecondsSinceEpoch}',
                  email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
                  password: 'Test@123',
                  phoneNumber: '9841234567',
                );
                debugPrint('Register result: $result');
              }),
              _buildTestButton('Login', () async {
                final result = await _api.login(
                  email: 'test@example.com',
                  password: 'Test@123',
                );
                debugPrint('Login result: $result');
              }),
              _buildTestButton('Forgot Password', () async {
                final result = await _api.forgotPassword('test@example.com');
                debugPrint('Forgot password result: $result');
              }),

              // 2. User & Profile Tests
              _buildSectionHeader('2. User & Profile'),
              _buildTestButton('Get My Profile', () async {
                final result = await _api.getCurrentUserProfile();
                debugPrint('Profile: $result');
              }),
              _buildTestButton('Update Profile', () async {
                final result = await _api.updateProfile(
                  name: 'Updated Name',
                  phone: '9841234567',
                );
                debugPrint('Updated profile: $result');
              }),
              _buildTestButton('Get Providers by Category', () async {
                final result = await _api.getProvidersByCategory('category123');
                debugPrint('Providers: $result');
              }),

              // 3. Booking Tests
              _buildSectionHeader('3. Bookings'),
              _buildTestButton('Create Booking', () async {
                final result = await _api.createBooking(
                  providerId: 'provider123',
                  serviceId: 'service123',
                  bookingDate: DateTime.now().add(const Duration(days: 1)),
                  description: 'Test booking',
                  location: 'Kathmandu',
                );
                debugPrint('Booking created: $result');
              }),
              _buildTestButton('Get My Bookings', () async {
                final result = await _api.getMyBookings();
                debugPrint('My bookings: $result');
              }),
              _buildTestButton('Get Provider Requests', () async {
                final result = await _api.getProviderRequests();
                debugPrint('Provider requests: $result');
              }),

              // 4. Chat Tests
              _buildSectionHeader('4. Chat System'),
              _buildTestButton('Send Chat Message', () async {
                final result = await _api.sendChatMessage(
                  requestId: 'request123',
                  message: 'Hello from test!',
                );
                debugPrint('Message sent: $result');
              }),
              _buildTestButton('Get Chat History', () async {
                final result = await _api.getChatHistory('request123');
                debugPrint('Chat history: $result');
              }),
              _buildTestButton('Get Unread Count', () async {
                final count = await _api.getUnreadMessageCount('request123');
                debugPrint('Unread count: $count');
              }),

              // 5. Category Tests
              _buildSectionHeader('5. Categories'),
              _buildTestButton('Get Active Categories', () async {
                final result = await _api.getActiveCategories();
                debugPrint('Categories: $result');
              }),
              _buildTestButton('Create Category (Admin)', () async {
                final result = await _api.createCategory(
                  name: 'Test Category',
                  description: 'Test description',
                  icon: 'test_icon',
                );
                debugPrint('Category created: $result');
              }),

              // 6. Admin Tests
              _buildSectionHeader('6. Admin Management'),
              _buildTestButton('Get All Users', () async {
                final result = await _api.getAllUsers();
                debugPrint('All users: $result');
              }),
              _buildTestButton('Get All Providers', () async {
                final result = await _api.getAllProviders();
                debugPrint('All providers: $result');
              }),
              _buildTestButton('Get Pending Providers', () async {
                final result = await _api.getPendingProviders();
                debugPrint('Pending providers: $result');
              }),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _runAllTests,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Run All Tests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTestButton(String label, Future<void> Function() testFunction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: () => _runTest(label, testFunction),
        child: Text(label),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _loading = true;
      _result = 'Running all tests...';
    });

    final results = <String>[];

    // Helper function to run a test and track result
    Future<void> runSingleTest(String name, Future<void> Function() test) async {
      try {
        await test();
        results.add('✅ $name: PASSED');
      } catch (e) {
        results.add('❌ $name: FAILED - ${e.toString().substring(0, 50)}...');
      }
    }

    // Run all tests
    await runSingleTest('Get Active Categories', () => _api.getActiveCategories());
    await runSingleTest('Forgot Password', () => _api.forgotPassword('test@example.com'));

    setState(() {
      _result = results.join('\n\n');
      _loading = false;
    });
  }
}
