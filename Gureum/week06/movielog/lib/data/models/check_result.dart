class CheckResult {
  const CheckResult({required this.available});

  factory CheckResult.fromJson(Map<String, dynamic> json) =>
      CheckResult(available: json['available'] as bool? ?? false);

  final bool available;
}
