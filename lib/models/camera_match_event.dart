import 'visitor.dart';

class CameraMatchEvent {
  final String id;
  final Visitor visitor;
  final int? cameraId;
  final String cameraName;
  final String gateLocation;
  final double confidence;
  final String matchType; // ANPR / PLATE, FACE RECOGNITION, RE-ID
  final String eventType; // ENTRY or EXIT
  final String source;
  final String? snapshotUrl;
  final DateTime timestamp;
  final bool isFrequentVisitor;

  CameraMatchEvent({
    required this.id,
    required this.visitor,
    this.cameraId,
    this.cameraName = 'Gate 1 (Visitor Access)',
    this.gateLocation = 'North Gate Entrance',
    required this.confidence,
    required this.matchType,
    this.eventType = 'ENTRY',
    this.source = 'FACE',
    this.snapshotUrl,
    required this.timestamp,
    required this.isFrequentVisitor,
  });

  factory CameraMatchEvent.fromVisitor(
    Visitor visitor, {
    String cameraName = 'Gate 1 (Visitor Access)',
    String gateLocation = 'North Gate Entrance',
    double confidence = 0.94,
    String matchType = 'ANPR License Plate',
    String? snapshotUrl,
  }) {
    return CameraMatchEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      visitor: visitor,
      cameraId: null,
      cameraName: cameraName,
      gateLocation: gateLocation,
      confidence: confidence,
      matchType: matchType,
      eventType: 'ENTRY',
      source: 'MANUAL',
      snapshotUrl: snapshotUrl,
      timestamp: DateTime.now(),
      isFrequentVisitor: visitor.isFrequentVisitor,
    );
  }

  factory CameraMatchEvent.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
    final visitorJson = (json['visitor'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final snapshotPath = json['snapshot_path']?.toString();
    return CameraMatchEvent(
      id: json['id']?.toString() ??
          '${json['camera_id'] ?? 0}-${json['visitor_id'] ?? 0}-${json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch}',
      visitor: Visitor.fromJson(visitorJson),
      cameraId: json['camera_id'] is int
          ? json['camera_id'] as int
          : int.tryParse(json['camera_id']?.toString() ?? ''),
      cameraName: json['camera_name']?.toString() ?? 'Visitor Camera',
      gateLocation: json['gate_location']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      matchType: json['match_type']?.toString() ?? 'FACE_INSIGHTFACE',
      eventType: (json['event_type']?.toString() ?? 'ENTRY').toUpperCase(),
      source: (json['source']?.toString() ?? 'FACE').toUpperCase(),
      snapshotUrl: snapshotPath == null
          ? null
          : (snapshotPath.startsWith('http') ? snapshotPath : '$baseUrl/$snapshotPath'),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      isFrequentVisitor: json['visitor'] is Map
          ? visitorJson['total_visits'] is num && (visitorJson['total_visits'] as num) >= 2
          : false,
    );
  }
}
