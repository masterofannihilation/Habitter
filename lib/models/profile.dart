import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 4)
class Profile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String gender;

  @HiveField(2)
  DateTime dateOfBirth;

  @HiveField(3)
  String? bio;

  Profile({
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.bio,
  });
}