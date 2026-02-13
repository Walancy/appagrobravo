class EmergencyContacts {
  final String police;
  final String firefighters;
  final String medical;
  final String? countryName;

  const EmergencyContacts({
    required this.police,
    required this.firefighters,
    required this.medical,
    this.countryName,
  });
}
