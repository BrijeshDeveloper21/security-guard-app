// Visitor Approval model for resident workflow

import 'package:security_app/features/guard/models/visitor_visit.dart';

class VisitorApproval {
  final String id;
  final String tenantId;
  final String visitId;
  final String residentId;
  final String flatId;
  final String flatNumber;
  final String visitorName;
  final String visitorPhone;
  final String? visitorPhotoUrl;
  final VisitorType visitorType;
  final VisitPurpose purpose;
  final String entryGateName;
  final ApprovalStatus status;
  final DateTime requestedAt;
  final DateTime? respondedAt;
  final String? notes;
  final String? rejectionReason;

  const VisitorApproval({
    required this.id,
    required this.tenantId,
    required this.visitId,
    required this.residentId,
    required this.flatId,
    required this.flatNumber,
    required this.visitorName,
    required this.visitorPhone,
    this.visitorPhotoUrl,
    required this.visitorType,
    required this.purpose,
    required this.entryGateName,
    this.status = ApprovalStatus.pending,
    required this.requestedAt,
    this.respondedAt,
    this.notes,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'visitId': visitId,
        'residentId': residentId,
        'flatId': flatId,
        'flatNumber': flatNumber,
        'visitorName': visitorName,
        'visitorPhone': visitorPhone,
        'visitorPhotoUrl': visitorPhotoUrl,
        'visitorType': visitorType.name,
        'purpose': purpose.name,
        'entryGateName': entryGateName,
        'status': status.name,
        'requestedAt': requestedAt.toIso8601String(),
        'respondedAt': respondedAt?.toIso8601String(),
        'notes': notes,
        'rejectionReason': rejectionReason,
      };

  factory VisitorApproval.fromJson(Map<String, dynamic> json) =>
      VisitorApproval(
        id: json['id'],
        tenantId: json['tenantId'],
        visitId: json['visitId'],
        residentId: json['residentId'],
        flatId: json['flatId'],
        flatNumber: json['flatNumber'],
        visitorName: json['visitorName'],
        visitorPhone: json['visitorPhone'],
        visitorPhotoUrl: json['visitorPhotoUrl'],
        visitorType: VisitorType.values.firstWhere(
          (e) => e.name == json['visitorType'],
          orElse: () => VisitorType.guest,
        ),
        purpose: VisitPurpose.values.firstWhere(
          (e) => e.name == json['purpose'],
          orElse: () => VisitPurpose.meetingResident,
        ),
        entryGateName: json['entryGateName'] ?? 'Main Gate',
        status: ApprovalStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ApprovalStatus.pending,
        ),
        requestedAt: DateTime.parse(json['requestedAt']),
        respondedAt: json['respondedAt'] != null
            ? DateTime.parse(json['respondedAt'])
            : null,
        notes: json['notes'],
        rejectionReason: json['rejectionReason'],
      );

  VisitorApproval copyWith({
    String? id,
    String? tenantId,
    String? visitId,
    String? residentId,
    String? flatId,
    String? flatNumber,
    String? visitorName,
    String? visitorPhone,
    String? visitorPhotoUrl,
    VisitorType? visitorType,
    VisitPurpose? purpose,
    String? entryGateName,
    ApprovalStatus? status,
    DateTime? requestedAt,
    DateTime? respondedAt,
    String? notes,
    String? rejectionReason,
  }) {
    return VisitorApproval(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      visitId: visitId ?? this.visitId,
      residentId: residentId ?? this.residentId,
      flatId: flatId ?? this.flatId,
      flatNumber: flatNumber ?? this.flatNumber,
      visitorName: visitorName ?? this.visitorName,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      visitorPhotoUrl: visitorPhotoUrl ?? this.visitorPhotoUrl,
      visitorType: visitorType ?? this.visitorType,
      purpose: purpose ?? this.purpose,
      entryGateName: entryGateName ?? this.entryGateName,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
