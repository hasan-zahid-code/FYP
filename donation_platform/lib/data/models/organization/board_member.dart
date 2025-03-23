// lib/data/models/organization/board_member.dart
class BoardMember {
  final String name;
  final String position;
  final String? cnic;
  
  BoardMember({
    required this.name,
    required this.position,
    this.cnic,
  });
  
  factory BoardMember.fromJson(Map<String, dynamic> json) {
    return BoardMember(
      name: json['name'],
      position: json['position'],
      cnic: json['cnic'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'cnic': cnic,
    };
  }
}