import 'dart:io';
import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showEditNameDialog(AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Display Name'),
          content: TextField(
            controller: _displayNameController,
            decoration:
                const InputDecoration(hintText: "Enter new display name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final displayName = _displayNameController.text;
                authViewModel.updateUserProfile(displayName: displayName);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPhotoDialog(AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _pickImage();
                  Navigator.of(context).pop();
                  if (_selectedImage != null) {
                    authViewModel.updateUserProfile(photo: _selectedImage);
                  }
                },
                child: const Text('Pick Image from Gallery'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (authViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (authViewModel.isAuthenticated) {
            final user = authViewModel.user!;
            _displayNameController.text = user.displayName ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (user.photoURL != null || _selectedImage != null)
                    Center(
                      child: GestureDetector(
                        onTap: () => _showEditPhotoDialog(authViewModel),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : NetworkImage(user.photoURL) as ImageProvider,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Name: ${user.displayName}',
                          style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditNameDialog(authViewModel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Email: ${user.email}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        authViewModel.signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Not logged in'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditPhotoDialog(context.read<AuthViewModel>()),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
