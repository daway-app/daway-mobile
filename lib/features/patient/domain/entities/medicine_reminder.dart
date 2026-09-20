class MedicineReminder {
  final String id;
  final String name;
  final List<int> daysOfWeek;
  final int hour;
  final int minute;

  const MedicineReminder({
    required this.id,
    required this.name,
    required this.daysOfWeek,
    required this.hour,
    required this.minute,
  });

  bool get isDaily => daysOfWeek.length == 7;

  String get formattedTime {
    final period = hour < 12 ? 'ص' : 'م';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h $period';
  }

  String get scheduleLabel {
    if (isDaily) return 'يومياً';
    const dayNames = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    return daysOfWeek.map((d) => dayNames[d % 7]).join(' - ');
  }

  String get alertLabel {
    if (isDaily) return 'تنبيه يومياً الساعة $formattedTime';
    return 'تنبيه الساعة $formattedTime';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'daysOfWeek': daysOfWeek,
        'hour': hour,
        'minute': minute,
      };

  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    return MedicineReminder(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          List.generate(7, (i) => i),
      hour: json['hour'] as int? ?? 8,
      minute: json['minute'] as int? ?? 0,
    );
  }
}
