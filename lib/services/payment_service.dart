import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isYearly = false;
  Function? onSuccess;
  Function? onError;

  // Initialize
  void initialize() {
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handleSuccess,
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handleError,
    );
  }

  // Open payment
  void openPayment({
    required bool isYearly,
    required Function onSuccessCallback,
    required Function onErrorCallback,
  }) {
    _isYearly = isYearly;
    onSuccess = onSuccessCallback;
    onError = onErrorCallback;

    final int amount = isYearly ? 99900 : 19900; // in paise

    final options = {
      // IMPORTANT: Replace with your actual Razorpay Key ID
      'key': 'rzp_test_YOUR_KEY_ID', 
      'amount': amount,
      'name': 'Lumixo Premium',
      'description': isYearly
          ? 'Yearly Plan — ₹999'
          : 'Monthly Plan — ₹199',
      'prefill': {
        'email': FirebaseAuth
            .instance.currentUser?.email ??
            '',
      },
      'theme': {'color': '#E8A0B4'},
      // Enable UPI payments (including Google Pay and Paytm)
      'external': {
        'wallets': ['paytm'],
      }
    };

    _razorpay.open(options);
  }

  // Handle success
  void _handleSuccess(PaymentSuccessResponse response) async {
    final String? userId =
        FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      await _firestoreService.updatePremium(userId, _isYearly);
    }

    onSuccess?.call();
  }

  // Handle error
  void _handleError(PaymentFailureResponse response) {
    onError?.call(response.message);
  }

  // Dispose
  void dispose() {
    _razorpay.clear();
  }
}
