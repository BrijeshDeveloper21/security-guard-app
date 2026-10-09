// Wings and Flats structure for multi-building multi-wing societies

class Wing {
  final String id;
  final String tenantId;
  final String name; // e.g. Wing A, Wing B, Wing C
  final int totalFloors;
  final DateTime createdAt;

  const Wing({
    required this.id,
    required this.tenantId,
    required this.name,
    this.totalFloors = 15,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'totalFloors': totalFloors,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Wing.fromJson(Map<String, dynamic> json) => Wing(
        id: json['id'],
        tenantId: json['tenantId'],
        name: json['name'],
        totalFloors: json['totalFloors'] ?? 15,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}

class Flat {
  final String id;
  final String tenantId;
  final String wingId;
  final String wingName; // Wing B
  final String flatNumber; // B-1204
  final int floor; // 12
  final String? residentName;
  final String? residentPhone;
  final String? residentEmail;
  final bool isOccupied;

  const Flat({
    required this.id,
    required this.tenantId,
    required this.wingId,
    required this.wingName,
    required this.flatNumber,
    required this.floor,
    this.residentName,
    this.residentPhone,
    this.residentEmail,
    this.isOccupied = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'wingId': wingId,
        'wingName': wingName,
        'flatNumber': flatNumber,
        'floor': floor,
        'residentName': residentName,
        'residentPhone': residentPhone,
        'residentEmail': residentEmail,
        'isOccupied': isOccupied,
      };

  factory Flat.fromJson(Map<String, dynamic> json) => Flat(
        id: json['id'],
        tenantId: json['tenantId'],
        wingId: json['wingId'],
        wingName: json['wingName'] ?? 'Wing A',
        flatNumber: json['flatNumber'],
        floor: json['floor'] ?? 1,
        residentName: json['residentName'],
        residentPhone: json['residentPhone'],
        residentEmail: json['residentEmail'],
        isOccupied: json['isOccupied'] ?? true,
      );

  Flat copyWith({
    String? id,
    String? tenantId,
    String? wingId,
    String? wingName,
    String? flatNumber,
    int? floor,
    String? residentName,
    String? residentPhone,
    String? residentEmail,
    bool? isOccupied,
  }) {
    return Flat(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      wingId: wingId ?? this.wingId,
      wingName: wingName ?? this.wingName,
      flatNumber: flatNumber ?? this.flatNumber,
      floor: floor ?? this.floor,
      residentName: residentName ?? this.residentName,
      residentPhone: residentPhone ?? this.residentPhone,
      residentEmail: residentEmail ?? this.residentEmail,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }
}
