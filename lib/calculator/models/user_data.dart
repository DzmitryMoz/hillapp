// lib/calculator/models/user_data.dart

class UserData {
  final int age; // Возраст в годах
  final double weight; // Вес в килограммах

  UserData({
    required this.age,
    required this.weight,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      age: map['age'] as int,
      weight: (map['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'weight': weight,
    };
  }
}
