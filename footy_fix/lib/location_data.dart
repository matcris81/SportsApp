class LocationData {
  String locationName;
  double distance;

  LocationData({required this.locationName, required this.distance});

  Map<String, dynamic> toJson() => {
        'locationName': locationName,
        'distance': distance,
      };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        locationName: json['locationName'],
        distance: json['distance'],
      );
}
