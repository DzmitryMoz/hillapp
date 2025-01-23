// lib/models/user_input.dart

class UserInput {
  final String userName;
  final int age;
  final double weight;
  final Map<String, double> userResults;

  UserInput({
    required this.userName,
    required this.age,
    required this.weight,
    required this.userResults,
  });
}
