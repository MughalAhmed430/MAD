class SmartDevice {
  final String id;
  String name;
  String type;
  String room;
  bool isOn;
  double value;

  SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    this.isOn = false,
    this.value = 0.5,
  });

  SmartDevice copyWith({
    String? name,
    String? type,
    String? room,
    bool? isOn,
    double? value,
  }) {
    return SmartDevice(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      value: value ?? this.value,
    );
  }
}