import 'visitor.dart';

class CameraMatchEvent {
  final String id;
  final Visitor visitor;
  final String cameraName;
  final String gateLocation;
  final double confidence;
  final String matchType; // ANPR / PLATE, FACE RECOGNITION, RE-ID
  final String? snapshotUrl;
  final DateTime timestamp;
  final bool isFrequentVisitor;

  CameraMatchEvent({
    required this.id,
    required this.visitor,
    this.cameraName = 'Gate 1 (Visitor Access)',
    this.gateLocation = 'North Gate Entrance',
    required this.confidence,
    required this.matchType,
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
      cameraName: cameraName,
      gateLocation: gateLocation,
      confidence: confidence,
      matchType: matchType,
      snapshotUrl: snapshotUrl,
      timestamp: DateTime.now(),
      isFrequentVisitor: visitor.isFrequentVisitor,
    );
  }
}
