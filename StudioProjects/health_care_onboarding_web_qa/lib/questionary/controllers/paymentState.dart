import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';
import '../../injection.dart';
import '../models/questionary/QuestionaryReqModel.dart';
import '../models/questionary/questionary_repo.dart';

class PaymentState extends ChangeNotifier {
  bool _isLoading = false;
  String? _statusMessage;
  bool _showWebView = false;
  String? _paymentLink;
  String? _sessionId;
  InAppWebViewController? _webViewController;
  Timer? _pollingTimer;
  bool _isPaymentVerified = false;
  bool _disposed = false;

  set showWebView(bool value) {
    _showWebView = value;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;
  bool get showWebView => _showWebView;
  String? get paymentLink => _paymentLink;
  String? get sessionId => _sessionId;
  InAppWebViewController? get webViewController => _webViewController;

  late BuildContext _context;

  void setWebViewController(InAppWebViewController? controller) {
    _webViewController = controller;
    if (!_disposed) notifyListeners();
  }

  Future<void> fetchPaymentDetails(BuildContext context) async {
    _context = context;
    _isLoading = true;
    _statusMessage = null;
    if (!_disposed) notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
            'https://api-dev.march.health/monomarch/api/v1/stripe-services/get-checkout-session?paymentKey=EndoMasterCarePlanUser'),
        headers: {"ngrok-skip-browser-warning": "69420"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _paymentLink = data['data']['paymentLink'];
        _sessionId = data['data']['sessionId'];
      final  model=   await getIt.get<QuestionaryRepository>().get();

        QuestionaryReqModel newModel = QuestionaryReqModel(
          userQuestionary: model.userQuestionary,
          sessionId: _sessionId,
        );
        await getIt.get<QuestionaryRepository>().add(newModel);
      } else {
        throw Exception('Failed to fetch payment details: ${response.statusCode}');
      }
    } catch (e) {
      _statusMessage = 'Error fetching payment details: $e';
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }
  String originalUrl='';
  Future<void> initiatePayment() async {
    if (_paymentLink == null || _sessionId == null) {
      _statusMessage = 'Payment details not available. Please try again.';
      if (!_disposed) notifyListeners();
      return;
    }

    _isLoading = true;
    _statusMessage = null;
    if (!_disposed) notifyListeners();

    if (kIsWeb) {
      final uri = Uri.parse(_paymentLink!);
      if (await canLaunchUrl(uri)) {
        html.window.location.href = _paymentLink!;
       // _startPolling();
      } else {
        _statusMessage = 'Could not launch payment page.';
      }
    } else {
      _showWebView = true;
    }

    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  // void _startPolling() {
  //   _pollingTimer?.cancel();
  //   _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  //     // Get the current URL
  //     if (_isPaymentVerified || _disposed) {
  //       timer.cancel();
  //       return;
  //     }
  //     await verifyPayment();
  //   });
  // }

  // Future<void> verifyPayment() async {
  //   if (_sessionId == null || _isPaymentVerified || _disposed) return;
  //
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           'https://certainly-helpful-fish.ngrok-free.app/api/v1/stripe-services/get-checkout-session-status?sessionId=$_sessionId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         "ngrok-skip-browser-warning": "69420",
  //       },
  //     );
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = jsonDecode(response.body);
  //       final paymentStatus = data['data']['payment_status'].toString().toLowerCase();
  //
  //       if (paymentStatus == 'paid' || (kIsWeb && html.window.location.href.contains('success'))) {
  //         _isPaymentVerified = true;
  //         _statusMessage = 'Payment Successful! Thank you for your purchase.';
  //         _showWebView = false;
  //
  //         QuestionaryReqModel model = await getIt.get<QuestionaryRepository>().get();
  //         await sendData(model);
  //
  //
  //       } else if (data['status'] == 'canceled') {
  //         _statusMessage = 'Payment cancelled. Please try again.';
  //         _showWebView = false;
  //         AutoRouter.of(_context).replace(const PurchaseFailedRoute());
  //       }
  //     } else {
  //       throw Exception('Failed to verify payment: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     _statusMessage = 'Payment verification failed: $e';
  //     AutoRouter.of(_context).replace(const PurchaseFailedRoute());
  //   } finally {
  //     if (_statusMessage != null && !_disposed) {
  //       _isLoading = false;
  //       notifyListeners();
  //       _clearStatusMessage();
  //     }
  //   }
  // }


  void _clearStatusMessage() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_disposed) {
        _statusMessage = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _pollingTimer?.cancel();
    super.dispose();
  }
}