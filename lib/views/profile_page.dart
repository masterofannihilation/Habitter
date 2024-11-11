import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitter_itu/constants.dart';
import 'package:habitter_itu/models/profile.dart';
import 'package:habitter_itu/controllers/profile_service.dart';
import 'package:habitter_itu/views/components/appbar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileService _profileService;
  Profile? _profile;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService();
    _bioController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    Profile? profile = await _profileService.getProfile();
    setState(() {
      _profile = profile ?? Profile(name: "John Doe", gender: "Unknown", dateOfBirth: DateTime.now(), bio: "");
      _bioController.text = _profile!.bio ?? '';
    });
  }

  void _changeName(String newName) {
    setState(() {
      _profile?.name = newName;
    });
    _saveProfile();
  }

  void _changeGender(String newGender) {
    setState(() {
      _profile?.gender = newGender;
    });
    _saveProfile();
  }

  void _changeDateOfBirth(DateTime newDateOfBirth) {
    setState(() {
      _profile?.dateOfBirth = newDateOfBirth;
    });
    _saveProfile();
  }

  void _changeBio(String newBio) {
    setState(() {
      _profile?.bio = newBio;
    });
    _saveProfile();
  }

  Future<void> _saveProfile() async {
    if (_profile != null) {
      await _profileService.saveProfile(_profile!);
    }
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: _profile?.name);
    TextEditingController genderController = TextEditingController(text: _profile?.gender);
    TextEditingController dateOfBirthController = TextEditingController(text: _profile?.dateOfBirth.toLocal().toString().split(' ')[0]);
    TextEditingController bioController = TextEditingController(text: _profile?.bio ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: dateOfBirthController,
                  decoration: InputDecoration(labelText: 'Date of Birth'),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _profile?.dateOfBirth ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      dateOfBirthController.text = pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                ),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(labelText: 'Bio'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _changeName(nameController.text);
                _changeGender(genderController.text);
                _changeDateOfBirth(DateTime.parse(dateOfBirthController.text));
                _changeBio(bioController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: CustomAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: habitColor, // Set background color to habitColor
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                      child: SvgPicture.asset(
                        'assets/profile.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile!.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _profile!.gender,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _profile!.dateOfBirth.toLocal().toString().split(' ')[0],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _profile!.bio ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  style: TextStyle(color: Colors.white), // Set text color to white
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    labelStyle: TextStyle(color: Colors.white), // Set label color to white
                    fillColor: habitColor, // Set background color to habitColor
                    filled: true, // Enable filling the background color
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set border color to white
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white), // Set border color to white when focused
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (newBio) {
                    _changeBio(newBio);
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: _showEditDialog,
            ),  
          ),
        ],
      ),
    );
  }
}