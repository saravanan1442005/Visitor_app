class VisitorEntry {
  final int id;
  final int visitorId;
  final String eventType; // ENTRY or EXIT
  final String source;    // MANUAL, PLATE, FACE, REID, PHONE
  final double? confidence;
  final bool confirmed;
  final String? snapshotPath;
  final DateTime timestamp;

  VisitorEntry({
    required this.id,
    required this.visitorId,
    required this.eventType,
    required this.source,
    this.confidence,
    this.confirmed = true,
    this.snapshotPath,
    required this.timestamp,
  });

  factory VisitorEntry.fromJson(Map<String, dynamic> json) {
    return VisitorEntry(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      visitorId: json['visitor_id'] is int ? json['visitor_id'] : int.tryParse(json['visitor_id'].toString()) ?? 0,
      eventType: json['event_type'] ?? 'ENTRY',
      source: json['source'] ?? 'MANUAL',
      confidence: json['confidence'] != null ? double.tryParse(json['confidence'].toString()) : null,
      confirmed: json['confirmed'] == true || json['confirmed'] == 1,
      snapshotPath: json['snapshot_path'],
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
