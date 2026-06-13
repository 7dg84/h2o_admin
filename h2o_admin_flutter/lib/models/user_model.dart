enum UserRole { citizen, operator, admin }

class UserModel {
  final String id;
  final String email;
  final String? curp;
  final String? name;
  final String? phone;
  final String? postalCode;
  final String? colonia;
  final String? street;
  final String? block;
  final String? exteriorNumber;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    this.curp,
    this.name,
    this.phone,
    this.postalCode,
    this.colonia,
    this.street,
    this.block,
    this.exteriorNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      curp: json['curp'],
      name: json['name'],
      phone: json['phone'],
      postalCode: json['postal_code'],
      colonia: json['colonia'],
      street: json['street'],
      block: json['block'],
      exteriorNumber: json['exterior_number'],
      role: _parseRole(json['role']),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'operator':
        return UserRole.operator;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.citizen;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'curp': curp,
      'name': name,
      'phone': phone,
      'postal_code': postalCode,
      'colonia': colonia,
      'street': street,
      'block': block,
      'exterior_number': exteriorNumber,
      'role': role.toString().split('.').last,
    };
  }
}
