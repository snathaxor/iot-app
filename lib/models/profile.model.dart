import '../enum/access.enum.dart';

class Profile {
  String email;
  String name;
  String code;
  String phone;
  String temperatureUnit;
  bool is24Hours;
  List<ConnectedDevice> devices;
  List<ConnectedDevice> accessesProvidedToUsers;
  String fcmToken;

  Profile({
    required this.email,
    required this.name,
    required this.code,
    required this.phone,
    required this.temperatureUnit,
    required this.is24Hours,
    required this.devices,
    required this.accessesProvidedToUsers,
    required this.fcmToken,
  });

  factory Profile.fromMap(Map<String, dynamic> data) {
    return Profile(
      email: data['email'],
      name: data['name'],
      code: data['code'],
      phone: data['phone'],
      temperatureUnit: data['temperatureUnit'],
      is24Hours: data['is24Hours'],
      devices: (data['devices'] as List).map((item) => ConnectedDevice.fromMap((item as Map).cast<String, dynamic>())).toList(),
      accessesProvidedToUsers: (data['access'] as List).map((item) => ConnectedDevice.fromMap((item as Map).cast<String, dynamic>())).toList(),
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "email": email,
      "name": name,
      "code": code,
      "phone": phone,
      "temperatureUnit": temperatureUnit,
      "is24Hours": is24Hours,
      "fcmToken": fcmToken,
    };
  }

  void updateProfile(String key, dynamic value) {
    final Map<String, dynamic> data = toJSON();
    data[key] = value;

    email = data['email'];
    name = data['name'];
    code = data['code'];
    phone = data['phone'];
    temperatureUnit = data['temperatureUnit'];
    is24Hours = data['is24Hours'];
    fcmToken = data['fcmToken'];
  }
}

class ConnectedDevice {
  String id;
  String deviceID;
  String? accessProvidedBy;
  AccessType accessType;
  String? userID;
  String? key;
  String? nickName;

  ConnectedDevice({
    required this.id,
    required this.deviceID,
    required this.accessType,
    required this.userID,
    this.key,
    this.accessProvidedBy,
    this.nickName,
  });

  factory ConnectedDevice.fromMap(Map<String, dynamic> data) {
    return ConnectedDevice(
      id: data['id'],
      deviceID: data['deviceID'],
      accessProvidedBy: data['accessProvidedBy'],
      accessType: AccessTypeExtension.getAccessType(data['accessType']),
      userID: data['userID'],
      key: data['key'],
      nickName: data['nickName'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "deviceID": deviceID,
      "accessProvidedBy": accessProvidedBy,
      "accessType": accessType.value,
      "userID": userID,
      "key": key,
      "nickName": nickName,
    };
  }
}
