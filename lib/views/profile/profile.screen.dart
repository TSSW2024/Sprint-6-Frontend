import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (user['photoURL'] != null)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user['photoURL']),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('Name: ${user['displayName']}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Email: ${user['email']}',
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
    );
  }
}
