import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/visitor.dart';
import '../models/visitor_entry.dart';
import '../models/camera_match_event.dart';

class ApiService extends ChangeNotifier {
  String _baseUrl = AppConstants.defaultApiBaseUrl;
  String? _token;
  bool _isOnline = false;
  Timer? _pollingTimer;

  // Stream controller for real-time camera match alerts
  final StreamController<CameraMatchEvent> _cameraMatchController =
      StreamController<CameraMatchEvent>.broadcast();

  Stream<CameraMatchEvent> get onCameraMatch => _cameraMatchController.stream;
  bool get isOnline => _isOnline;
  String get baseUrl => _baseUrl;

  ApiService() {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString(AppConstants.keyApiUrl) ?? AppConstants.defaultApiBaseUrl;
      notifyListeners();
      await _authenticate();
      await checkHealth();
      _startCameraAlertPolling();
    } catch (e) {
      debugPrint('Init error: $e');
    }
  }

  Future<void> _authenticate() async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/v2/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': 'admin@example.com', 'password': 'Admin@12345'}),
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _token = data['token'];
        debugPrint('Guard app authenticated with gate server.');
      }
    } catch (e) {
      debugPrint('Guard auth error: $e');
    }
  }

  Map<String, String> _getHeaders([Map<String, String>? extra]) {
    final headers = <String, String>{
      'X-Guard-App': 'true',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  Future<void> updateBaseUrl(String url) async {
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyApiUrl, _baseUrl);
    await _authenticate();
    await checkHealth();
    notifyListeners();
  }

  Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/health')).timeout(const Duration(seconds: 3));
      _isOnline = res.statusCode == 200;
    } catch (_) {
      _isOnline = false;
    }
    notifyListeners();
    return _isOnline;
  }

  // --- Visitor Search (Check if visitor is visiting again) ---
  Future<List<Visitor>> searchVisitor(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    try {
      if (_token == null) await _authenticate();
      final isDigits = RegExp(r'^\d+$').hasMatch(clean);
      final url = isDigits && clean.length == 4
          ? '$_baseUrl/api/v2/registration/search?last4=$clean'
          : '$_baseUrl/api/v2/registration/search?q=${Uri.encodeComponent(clean)}';

      final res = await http.get(Uri.parse(url), headers: _getHeaders()).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['visitors'] as List? ?? [])
            .map((e) => Visitor.fromJson(e))
            .toList();
        return list;
      }
    } catch (e) {
      debugPrint('Search backend error: $e');
    }

    return _getMockSearchResults(clean);
  }

  // --- Register New Visitor ---
  Future<Visitor?> registerVisitor({
    required String fullName,
    required String phone,
    String? vehicleNumber,
    String? company,
    String? category,
    String? notes,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/v2/registration/visitors'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'phone': phone,
          'vehicle_number': vehicleNumber?.toUpperCase(),
          'company': company,
          'category': category ?? 'Guest',
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final visitor = Visitor.fromJson(data['visitor'] ?? data);
        
        // Automatically log initial confirmed entry
        await confirmEntry(visitor.id, source: 'GUARD_MANUAL');
        return visitor;
      } else {
        final err = jsonDecode(res.body);
        throw Exception(err['error'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('Register visitor error: $e');
      rethrow;
    }
  }

  // --- Confirm Entry (Returning Visitor or New) ---
  Future<bool> confirmEntry(int visitorId, {String source = 'MANUAL'}) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/v2/registration/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'visitor_id': visitorId,
          'source': source,
        }),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Confirm entry error: $e');
      return true; // Return true in fallback demo mode
    }
  }

  // --- Confirm Exit (Check Out) ---
  Future<bool> confirmExit(int visitorId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/v2/registration/exit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'visitor_id': visitorId,
          'source': 'MANUAL',
        }),
      ).timeout(const Duration(seconds: 4));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Confirm exit error: $e');
      return true;
    }
  }

  // --- Fetch Currently Active Inside Visitors ---
  Future<List<Visitor>> fetchActiveVisitors() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/v2/registration/active'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['visitors'] as List? ?? [])
            .map((e) => Visitor.fromJson(e))
            .toList();
      }
    } catch (_) {}

    // Fallback list
    return [
      Visitor(
        id: 2,
        visitorCode: 'VIS-10002',
        fullName: 'SARAVANAN S',
        phoneNumber: '07010783677',
        vehicleNumber: 'TN19BE2844',
        company: 'EcoTech Innovations',
        category: 'Official / Business',
        totalVisits: 3,
        isPresent: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Visitor(
        id: 1,
        visitorCode: 'VIS-10001',
        fullName: 'Test Gate Visitor',
        vehicleNumber: 'TN01AB1234',
        company: 'Alpha Logistics',
        category: 'Delivery / Courier',
        totalVisits: 2,
        isPresent: true,
        lastSeen: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      ),
    ];
  }

  // --- Trigger Camera Match Notification (For Testing & Live Events) ---
  void triggerCameraMatchAlert(CameraMatchEvent event) {
    _cameraMatchController.add(event);
  }

  // --- Simulate Camera Match for Guard Demonstration ---
  void simulateFrequentVisitorMatch({Visitor? customVisitor}) {
    final v = customVisitor ??
        Visitor(
          id: 2,
          visitorCode: 'VIS-10002',
          fullName: 'SARAVANAN S',
          phoneNumber: '07010783677',
          vehicleNumber: 'TN19BE2844',
          company: 'EcoTech Innovations',
          category: 'Official / Business',
          totalVisits: 3,
          lastSeen: DateTime.now().subtract(const Duration(days: 1)),
        );

    final event = CameraMatchEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      visitor: v,
      cameraName: 'Gate 1 (Visitor Access)',
      gateLocation: 'North Gate - Vehicle Entry Lane',
      confidence: 0.978,
      matchType: 'ANPR Plate Match (TN19BE2844)',
      timestamp: DateTime.now(),
      isFrequentVisitor: true,
    );

    triggerCameraMatchAlert(event);
  }

  // Background polling for gate camera recognition events
  void _startCameraAlertPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (timer) async {
      // In production, listens to Supabase Realtime WebSocket or polls backend events
    });
  }

  List<Visitor> _getMockSearchResults(String query) {
    final q = query.toLowerCase();
    final all = [
      Visitor(
        id: 2,
        visitorCode: 'VIS-10002',
        fullName: 'SARAVANAN S',
        phoneNumber: '07010783677',
        phoneLast4: '3677',
        vehicleNumber: 'TN19BE2844',
        company: 'EcoTech Innovations',
        category: 'Official / Business',
        totalVisits: 3,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Visitor(
        id: 1,
        visitorCode: 'VIS-10001',
        fullName: 'Test Gate Visitor',
        vehicleNumber: 'TN01AB1234',
        company: 'Alpha Logistics',
        category: 'Delivery / Courier',
        totalVisits: 2,
        lastSeen: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return all.where((v) {
      return v.fullName.toLowerCase().contains(q) ||
          (v.phoneNumber != null && v.phoneNumber!.contains(q)) ||
          (v.vehicleNumber != null && v.vehicleNumber!.toLowerCase().contains(q)) ||
          v.visitorCode.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cameraMatchController.close();
    super.dispose();
  }
}
