class Visitor {
  final int id;
  final String visitorCode;
  final String fullName;
  final String? phoneNumber;
  final String? phoneLast4;
  final String? company;
  final String? vehicleNumber;
  final String? category;
  final String? profilePhotoPath;
  final int totalVisits;
  final DateTime? firstSeen;
  final DateTime? lastSeen;
  final String status;
  final bool isPresent;

  Visitor({
    required this.id,
    required this.visitorCode,
    required this.fullName,
    this.phoneNumber,
    this.phoneLast4,
    this.company,
    this.vehicleNumber,
    this.category,
    this.profilePhotoPath,
    this.totalVisits = 1,
    this.firstSeen,
    this.lastSeen,
    this.status = 'ACTIVE',
    this.isPresent = false,
  });

  bool get isFrequentVisitor => totalVisits >= 2;

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      visitorCode: json['visitor_code'] ?? '',
      fullName: json['full_name'] ?? 'Unknown Visitor',
      phoneNumber: json['phone_number'],
      phoneLast4: json['phone_last4'],
      company: json['company'],
      vehicleNumber: json['vehicle_number'],
      category: json['category'] ?? 'Guest',
      profilePhotoPath: json['profile_photo_path'],
      totalVisits: json['total_visits'] is int ? json['total_visits'] : int.tryParse(json['total_visits']?.toString() ?? '1') ?? 1,
      firstSeen: json['first_seen'] != null ? DateTime.tryParse(json['first_seen'].toString()) : null,
      lastSeen: json['last_seen'] != null ? DateTime.tryParse(json['last_seen'].toString()) : null,
      status: json['status'] ?? 'ACTIVE',
      isPresent: json['is_present'] == true || json['is_present'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor_code': visitorCode,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'phone_last4': phoneLast4,
      'company': company,
      'vehicle_number': vehicleNumber,
      'category': category,
      'profile_photo_path': profilePhotoPath,
      'total_visits': totalVisits,
      'status': status,
      'is_present': isPresent,
    };
  }
}
