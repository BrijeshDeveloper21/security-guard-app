// Visitor and Visit entities with full entry/exit and approval tracking

enum VisitorType {
  guest,
  delivery,
  cab,
  technician,
  domesticHelp,
  vendor,
  other,
}

extension VisitorTypeExt on VisitorType {
  String get nameDisplay {
    switch (this) {
      case VisitorType.guest:
        return 'Guest';
      case VisitorType.delivery:
        return 'Delivery';
      case VisitorType.cab:
        return 'Cab';
      case VisitorType.technician:
        return 'Technician';
      case VisitorType.domesticHelp:
        return 'Domestic Help';
      case VisitorType.vendor:
        return 'Vendor';
      case VisitorType.other:
        return 'Other';
    }
  }

  String get iconAsset {
    switch (this) {
      case VisitorType.guest:
        return '👤';
      case VisitorType.delivery:
        return '📦';
      case VisitorType.cab:
        return '🚕';
      case VisitorType.technician:
        return '🔧';
      case VisitorType.domesticHelp:
        return '🧹';
      case VisitorType.vendor:
        return '🛒';
      case VisitorType.other:
        return '🏷️';
    }
  }
}

enum VisitPurpose {
  meetingResident,
  delivery,
  repair,
  maintenance,
  service,
  domesticWork,
  cabPickupDrop,
  other,
}

extension VisitPurposeExt on VisitPurpose {
  String get nameDisplay {
    switch (this) {
      case VisitPurpose.meetingResident:
        return 'Meeting Resident';
      case VisitPurpose.delivery:
        return 'Delivery';
      case VisitPurpose.repair:
        return 'Repair';
      case VisitPurpose.maintenance:
        return 'Maintenance';
      case VisitPurpose.service:
        return 'Service';
      case VisitPurpose.domesticWork:
        return 'Domestic Work';
      case VisitPurpose.cabPickupDrop:
        return 'Cab Pickup/Drop';
      case VisitPurpose.other:
        return 'Other';
    }
  }
}

enum VisitStatus {
  inside,
  exited,
  rejected,
}

extension VisitStatusExt on VisitStatus {
  String get nameDisplay {
    switch (this) {
      case VisitStatus.inside:
        return 'INSIDE';
      case VisitStatus.exited:
        return 'EXITED';
      case VisitStatus.rejected:
        return 'REJECTED';
    }
  }
}

enum ApprovalStatus {
  notRequired,
  pending,
  approved,
  rejected,
}

extension ApprovalStatusExt on ApprovalStatus {
  String get nameDisplay {
    switch (this) {
      case ApprovalStatus.notRequired:
        return 'NOT REQUIRED';
      case ApprovalStatus.pending:
        return 'PENDING';
      case ApprovalStatus.approved:
        return 'APPROVED';
      case ApprovalStatus.rejected:
        return 'REJECTED';
    }
  }
}

class Visitor {
  final String id;
  final String tenantId;
  final String name;
  final String phone;
  final String? photoUrl;
  final String? vehicleNumber;
  final VisitorType visitorType;
  final int totalVisits;
  final String? lastVisitedFlat;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime? lastVisitAt;

  const Visitor({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.vehicleNumber,
    this.visitorType = VisitorType.guest,
    this.totalVisits = 1,
    this.lastVisitedFlat,
    this.isBlocked = false,
    required this.createdAt,
    this.lastVisitAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'phone': phone,
        'photoUrl': photoUrl,
        'vehicleNumber': vehicleNumber,
        'visitorType': visitorType.name,
        'totalVisits': totalVisits,
        'lastVisitedFlat': lastVisitedFlat,
        'isBlocked': isBlocked,
        'createdAt': createdAt.toIso8601String(),
        'lastVisitAt': lastVisitAt?.toIso8601String(),
      };

  factory Visitor.fromJson(Map<String, dynamic> json) => Visitor(
        id: json['id'],
        tenantId: json['tenantId'],
        name: json['name'],
        phone: json['phone'],
        photoUrl: json['photoUrl'],
        vehicleNumber: json['vehicleNumber'],
        visitorType: VisitorType.values.firstWhere(
          (e) => e.name == json['visitorType'],
          orElse: () => VisitorType.guest,
        ),
        totalVisits: json['totalVisits'] ?? 1,
        lastVisitedFlat: json['lastVisitedFlat'],
        isBlocked: json['isBlocked'] ?? false,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
        lastVisitAt: json['lastVisitAt'] != null
            ? DateTime.parse(json['lastVisitAt'])
            : null,
      );

  Visitor copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? phone,
    String? photoUrl,
    String? vehicleNumber,
    VisitorType? visitorType,
    int? totalVisits,
    String? lastVisitedFlat,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? lastVisitAt,
  }) {
    return Visitor(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      visitorType: visitorType ?? this.visitorType,
      totalVisits: totalVisits ?? this.totalVisits,
      lastVisitedFlat: lastVisitedFlat ?? this.lastVisitedFlat,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
    );
  }
}

class Visit {
  final String id; // e.g. VIS-2026-000123
  final String tenantId;
  final String visitorId;
  final String visitorName;
  final String visitorPhone;
  final String? visitorPhotoUrl;
  final String flatId;
  final String flatNumber; // B-1204
  final String wingName; // Wing B
  final VisitorType visitorType;
  final VisitPurpose purpose;
  final String? customPurpose;
  final String? vehicleNumber;
  final String entryGateId;
  final String entryGateName; // Gate A - Main Gate
  final String entryGuardId;
  final String entryGuardName;
  final DateTime entryTimestamp; // Automatic recorded
  final String? exitGateId;
  final String? exitGateName; // Gate B - Parking
  final String? exitGuardId;
  final String? exitGuardName;
  final DateTime? exitTimestamp; // Automatic recorded
  final VisitStatus status;
  final ApprovalStatus approvalStatus;
  final String secureVisitToken; // QR Token
  final bool isPreApproved;
  final DateTime? expectedArrivalTime;
  final String? notes;
  final String? rejectionReason;

  const Visit({
    required this.id,
    required this.tenantId,
    required this.visitorId,
    required this.visitorName,
    required this.visitorPhone,
    this.visitorPhotoUrl,
    required this.flatId,
    required this.flatNumber,
    required this.wingName,
    required this.visitorType,
    required this.purpose,
    this.customPurpose,
    this.vehicleNumber,
    required this.entryGateId,
    required this.entryGateName,
    required this.entryGuardId,
    required this.entryGuardName,
    required this.entryTimestamp,
    this.exitGateId,
    this.exitGateName,
    this.exitGuardId,
    this.exitGuardName,
    this.exitTimestamp,
    this.status = VisitStatus.inside,
    this.approvalStatus = ApprovalStatus.notRequired,
    required this.secureVisitToken,
    this.isPreApproved = false,
    this.expectedArrivalTime,
    this.notes,
    this.rejectionReason,
  });

  bool get isInside => status == VisitStatus.inside && exitTimestamp == null;
  bool get isExited => status == VisitStatus.exited && exitTimestamp != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'visitorId': visitorId,
        'visitorName': visitorName,
        'visitorPhone': visitorPhone,
        'visitorPhotoUrl': visitorPhotoUrl,
        'flatId': flatId,
        'flatNumber': flatNumber,
        'wingName': wingName,
        'visitorType': visitorType.name,
        'purpose': purpose.name,
        'customPurpose': customPurpose,
        'vehicleNumber': vehicleNumber,
        'entryGateId': entryGateId,
        'entryGateName': entryGateName,
        'entryGuardId': entryGuardId,
        'entryGuardName': entryGuardName,
        'entryTimestamp': entryTimestamp.toIso8601String(),
        'exitGateId': exitGateId,
        'exitGateName': exitGateName,
        'exitGuardId': exitGuardId,
        'exitGuardName': exitGuardName,
        'exitTimestamp': exitTimestamp?.toIso8601String(),
        'status': status.name,
        'approvalStatus': approvalStatus.name,
        'secureVisitToken': secureVisitToken,
        'isPreApproved': isPreApproved,
        'expectedArrivalTime': expectedArrivalTime?.toIso8601String(),
        'notes': notes,
        'rejectionReason': rejectionReason,
      };

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
        id: json['id'],
        tenantId: json['tenantId'],
        visitorId: json['visitorId'],
        visitorName: json['visitorName'],
        visitorPhone: json['visitorPhone'],
        visitorPhotoUrl: json['visitorPhotoUrl'],
        flatId: json['flatId'],
        flatNumber: json['flatNumber'],
        wingName: json['wingName'] ?? '',
        visitorType: VisitorType.values.firstWhere(
          (e) => e.name == json['visitorType'],
          orElse: () => VisitorType.guest,
        ),
        purpose: VisitPurpose.values.firstWhere(
          (e) => e.name == json['purpose'],
          orElse: () => VisitPurpose.meetingResident,
        ),
        customPurpose: json['customPurpose'],
        vehicleNumber: json['vehicleNumber'],
        entryGateId: json['entryGateId'],
        entryGateName: json['entryGateName'],
        entryGuardId: json['entryGuardId'],
        entryGuardName: json['entryGuardName'],
        entryTimestamp: DateTime.parse(json['entryTimestamp']),
        exitGateId: json['exitGateId'],
        exitGateName: json['exitGateName'],
        exitGuardId: json['exitGuardId'],
        exitGuardName: json['exitGuardName'],
        exitTimestamp: json['exitTimestamp'] != null
            ? DateTime.parse(json['exitTimestamp'])
            : null,
        status: VisitStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => VisitStatus.inside,
        ),
        approvalStatus: ApprovalStatus.values.firstWhere(
          (e) => e.name == json['approvalStatus'],
          orElse: () => ApprovalStatus.notRequired,
        ),
        secureVisitToken: json['secureVisitToken'] ?? json['id'],
        isPreApproved: json['isPreApproved'] ?? false,
        expectedArrivalTime: json['expectedArrivalTime'] != null
            ? DateTime.parse(json['expectedArrivalTime'])
            : null,
        notes: json['notes'],
        rejectionReason: json['rejectionReason'],
      );

  Visit copyWith({
    String? id,
    String? tenantId,
    String? visitorId,
    String? visitorName,
    String? visitorPhone,
    String? visitorPhotoUrl,
    String? flatId,
    String? flatNumber,
    String? wingName,
    VisitorType? visitorType,
    VisitPurpose? purpose,
    String? customPurpose,
    String? vehicleNumber,
    String? entryGateId,
    String? entryGateName,
    String? entryGuardId,
    String? entryGuardName,
    DateTime? entryTimestamp,
    String? exitGateId,
    String? exitGateName,
    String? exitGuardId,
    String? exitGuardName,
    DateTime? exitTimestamp,
    VisitStatus? status,
    ApprovalStatus? approvalStatus,
    String? secureVisitToken,
    bool? isPreApproved,
    DateTime? expectedArrivalTime,
    String? notes,
    String? rejectionReason,
  }) {
    return Visit(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      visitorId: visitorId ?? this.visitorId,
      visitorName: visitorName ?? this.visitorName,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      visitorPhotoUrl: visitorPhotoUrl ?? this.visitorPhotoUrl,
      flatId: flatId ?? this.flatId,
      flatNumber: flatNumber ?? this.flatNumber,
      wingName: wingName ?? this.wingName,
      visitorType: visitorType ?? this.visitorType,
      purpose: purpose ?? this.purpose,
      customPurpose: customPurpose ?? this.customPurpose,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      entryGateId: entryGateId ?? this.entryGateId,
      entryGateName: entryGateName ?? this.entryGateName,
      entryGuardId: entryGuardId ?? this.entryGuardId,
      entryGuardName: entryGuardName ?? this.entryGuardName,
      entryTimestamp: entryTimestamp ?? this.entryTimestamp,
      exitGateId: exitGateId ?? this.exitGateId,
      exitGateName: exitGateName ?? this.exitGateName,
      exitGuardId: exitGuardId ?? this.exitGuardId,
      exitGuardName: exitGuardName ?? this.exitGuardName,
      exitTimestamp: exitTimestamp ?? this.exitTimestamp,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      secureVisitToken: secureVisitToken ?? this.secureVisitToken,
      isPreApproved: isPreApproved ?? this.isPreApproved,
      expectedArrivalTime: expectedArrivalTime ?? this.expectedArrivalTime,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
