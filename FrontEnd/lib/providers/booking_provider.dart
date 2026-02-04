import 'package:flutter/foundation.dart';
import 'package:HamroGharSewa/models/booking_model.dart';
import 'package:HamroGharSewa/services/booking_service.dart';
import 'package:HamroGharSewa/providers/chat_provider.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;
  ChatProvider? _chatProvider; // Optional chat provider reference
  
  List<Booking> _userBookings = [];
  List<Booking> _providerBookings = [];
  bool _isLoading = false;
  String? _error;

  BookingProvider(this._bookingService);

  /// Set chat provider to enable message reveal on booking acceptance
  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }

  List<Booking> get userBookings => _userBookings;
  List<Booking> get providerBookings => _providerBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter bookings by status
  List<Booking> get pendingBookings => 
      _providerBookings.where((b) => b.isPending).toList();
  
  List<Booking> get acceptedBookings => 
      _providerBookings.where((b) => b.isAccepted).toList();
  
  List<Booking> get completedBookings => 
      _providerBookings.where((b) => b.isCompleted).toList();

  /// Create a new booking
  Future<bool> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingDate,
    String? description,
    String? location,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      // DEMO MODE: Simulate API call if needed or just proceed
      // For now, we assume _bookingService.createBooking might act as a mock or we catch error
      
      Booking booking;
      try {
         booking = await _bookingService.createBooking(
          providerId: providerId,
          serviceId: serviceId,
          bookingDate: bookingDate,
          description: description,
          location: location,
        );
      } catch (e) {
        // Fallback for Demo if API fails/is not connected
        booking = Booking(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user_1',
          providerId: providerId,
          serviceId: serviceId,
          serviceName: 'Requested Service', // Placeholder
          providerName: 'Provider Recipient',
          userName: 'Current User',
          status: 'PENDING',
          bookingDate: bookingDate,
          description: description,
          location: location,
          createdAt: DateTime.now(),
        );
      }

      _userBookings.insert(0, booking);
      
      // FOR DEMO: Automatically add to provider bookings so we can see it in Provider Dashboard
      _providerBookings.insert(0, booking);
      
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Fetch user bookings
  Future<void> fetchUserBookings() async {
    _setLoading(true);
    _error = null;

    try {
      _userBookings = await _bookingService.getUserBookings();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Fetch provider bookings
  Future<void> fetchProviderBookings() async {
    _setLoading(true);
    _error = null;

    try {
      _providerBookings = await _bookingService.getProviderBookings();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Accept a booking (Provider)
  Future<bool> acceptBooking(String bookingId) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedBooking = await _bookingService.acceptBooking(bookingId);

      _updateBookingInList(updatedBooking);
      
      // Reveal all hidden messages for this booking
      if (_chatProvider != null) {
        await _chatProvider!.revealMessagesForBooking(bookingId);
      }
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Reject a booking (Provider)
  Future<bool> rejectBooking(String bookingId, {String? reason}) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedBooking = await _bookingService.rejectBooking(bookingId, reason: reason);

      _updateBookingInList(updatedBooking);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Complete a booking
  Future<bool> completeBooking(String bookingId) async {
    _setLoading(true);
    _error = null;

    try {
      final updatedBooking = await _bookingService.completeBooking(bookingId);

      _updateBookingInList(updatedBooking);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _updateBookingInList(Booking updatedBooking) {
    final index = _providerBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      _providerBookings[index] = updatedBooking;
    }

    final userIndex = _userBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (userIndex != -1) {
      _userBookings[userIndex] = updatedBooking;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (!value) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _userBookings = [];
    _providerBookings = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
