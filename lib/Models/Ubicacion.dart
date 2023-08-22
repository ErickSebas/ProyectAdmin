class Ubicacion {
  final String name;
  final String latitude;
  final String longitude;

  Ubicacion({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };
}
