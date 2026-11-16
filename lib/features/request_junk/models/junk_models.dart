import 'package:meta/meta.dart';
enum JunkRequestStatus {
  pickupScheduled('Pickup Scheduled'),
  offerPending('Offer Pending'),
  completed('Completed'),
  cancelled('Cancelled');
  final String label;
  const JunkRequestStatus(this.label);
}

/// Model representing a junk request.
@immutable
class JunkRequest {
  const JunkRequest({
    required this.id,
    required this.status,
    required this.vehicleTitle,
    required this.date,
    required this.vin,
    required this.condition,
    required this.notes,
    required this.salvageYardName,
    required this.salvageYardPhone,
    this.offerAmount,
    this.pickupDateTime,
    this.towCompany,
  });
  final String id;
  final JunkRequestStatus status;
  final String vehicleTitle;
  final String date;
  final String vin;
  final String condition;
  final String notes;
  final String salvageYardName;
  final String salvageYardPhone;
  final int? offerAmount;
  final String? pickupDateTime;
  final String? towCompany;

  factory JunkRequest.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'offerPending';
    JunkRequestStatus status;
    switch (statusStr) {
      case 'pickupScheduled':
        status = JunkRequestStatus.pickupScheduled;
      case 'completed':
        status = JunkRequestStatus.completed;
      case 'cancelled':
        status = JunkRequestStatus.cancelled;
      default:
        status = JunkRequestStatus.offerPending;
    }

    return JunkRequest(
      id: json['id'] as String? ?? '',
      status: status,
      vehicleTitle: json['vehicleTitle'] as String? ??
          '${json['year'] ?? ''} ${json['make'] ?? ''} ${json['model'] ?? ''}'.trim(),
      date: json['date'] as String? ?? 'Recent',
      vin: json['vin'] as String? ?? '',
      condition: json['condition'] as String? ?? 'Running – Good condition',
      notes: json['notes'] as String? ?? '',
      salvageYardName: json['salvageYardName'] as String? ?? 'AutoHub Express',
      salvageYardPhone: json['salvageYardPhone'] as String? ?? '',
      offerAmount: json['offerAmount'] as int?,
      pickupDateTime: json['pickupDateTime'] as String?,
      towCompany: json['towCompany'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'vehicleTitle': vehicleTitle,
      'date': date,
      'vin': vin,
      'condition': condition,
      'notes': notes,
      'salvageYardName': salvageYardName,
      'salvageYardPhone': salvageYardPhone,
      if (offerAmount != null) 'offerAmount': offerAmount,
      if (pickupDateTime != null) 'pickupDateTime': pickupDateTime,
      if (towCompany != null) 'towCompany': towCompany,
    };
  }
}
