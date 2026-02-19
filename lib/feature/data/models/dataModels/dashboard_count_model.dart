class DashboardCountModel {
  final int totalApplicationApproved;
  final int totalApplicationPending;
  final int totalApplicationRejected;
  final int totalRrNumber;
  final int totalPaymentPending;
  final int totalApplication;

  DashboardCountModel({
    required this.totalApplicationApproved,
    required this.totalApplicationPending,
    required this.totalApplicationRejected,
    required this.totalRrNumber,
    required this.totalPaymentPending,
    required this.totalApplication,
  });

  factory DashboardCountModel.fromJson(Map<String, dynamic> json) {
    return DashboardCountModel(
      totalApplicationApproved: json['applicationApproved'] ?? 0,
      totalApplicationPending: json['applicationPending'] ?? 0,
      totalApplicationRejected: json['applicationRejected'] ?? 0,
      totalRrNumber: json['rrNumberGenerated'] ?? 0,
      totalPaymentPending: json['paymentPending'] ?? 0,
      totalApplication: json['totalApplication'] ?? 0,
    );
  }
}
