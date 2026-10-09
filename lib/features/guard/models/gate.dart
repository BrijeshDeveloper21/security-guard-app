// Gate entity supporting dynamic unlimited gates

enum GateType {
  mainEntrance,
  parking,
  service,
  backGate,
  pedestrian,
  emergency,
}

extension GateTypeExt on GateType {
  String get nameDisplay {
    switch (this) {
      case GateType.mainEntrance:
        return 'Main Entrance';
      case GateType.parking:
        return 'Parking Gate';
      case GateType.service:
        return 'Service Entrance';
      case GateType.backGate:
        return 'Back Gate';
      case GateType.pedestrian:
        return 'Pedestrian Gate';
      case GateType.emergency:
        return 'Emergency Exit';
    }
  }
}

class Gate {
  final String id;
  final String tenantId;
  final String name; // e.g. Gate A - Main Entrance, Gate B - Parking
  final String code; // e.g. GATE-A, GATE-B
  final GateType type;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  const Gate({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.code,
    this.type = GateType.mainEntrance,
    this.description,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'code': code,
        'type': type.name,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Gate.fromJson(Map<String, dynamic> json) => Gate(
        id: json['id'],
        tenantId: json['tenantId'],
        name: json['name'],
        code: json['code'] ?? json['name'],
        type: GateType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => GateType.mainEntrance,
        ),
        description: json['description'],
        isActive: json['isActive'] ?? true,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );

  Gate copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? code,
    GateType? type,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Gate(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      code: code ?? this.code,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
